public protocol SyftLike {}

public enum Syft: SyftLike {

    case Match(String)
    case Sequence(SyftLike, SyftLike)
    case Name(String, SyftLike)
    case Repeat(SyftLike, minimum: Int, maximum: Int)
    
    public func parse(input: String) -> Result {
        return parse(Remainder(text: input, index: 0))
    }
    
    func parse(input: Remainder) -> Result {
        switch self {
            
        case let .Match(pattern):
            return parseMatch(input, pattern)

        case let .Sequence(first as Syft, second as Syft):
            return parseSequence(input, [first, second])
            
        case let .Name(name, sub as Syft):
            return parseName(input, name, sub)
            
        case let .Repeat(sub as Syft, minimum, maximum):
            return parseRepeat(input, sub, minimum: minimum, maximum: maximum, counter: 0)
            
        default:
            return .Failure
        }
    }
}

func parseMatch(input: Remainder, pattern: String) -> Result {
    
    if (pattern.isEmpty || input.text.hasPrefix(pattern)) {
        
        let (headText, tailText) = input.text.splitAtIndex(pattern.endIndex)
        let tailIndex = input.index + distance(headText.startIndex, headText.endIndex)
        let remainder = Remainder(text: tailText, index: tailIndex)
        
        return .Match(match: headText, index: input.index, remainder: remainder)
    }

    return .Failure
}

extension String {

    func splitAtIndex(index: String.Index) -> (String, String) {
        
        let head = self[self.startIndex..<index]
        let tail = self[index..<self.endIndex]
        
        return (head, tail)
    }
}

func parseSequence(input: Remainder, subs: [Syft]) -> Result {

    if let head = subs.head {
        return parseSequence(input, head, subs.tail)
    } else {
        return .Match(match: "", index: input.index, remainder: input)
    }
}

extension Array {
    
    var head : T? {
        return self.first
    }
    
    var tail : Array<T> {
        return count < 1 ? self : Array(self[1..<count])
    }
}

func parseSequence(input: Remainder, head: Syft, tail: [Syft]) -> Result {

    switch head.parse(input) {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: headText, index: headIndex, remainder: headRemainder):
        let tailResult = parseSequence(headRemainder, tail)
        return combineSequenceMatch(headText, headIndex, tailResult)
        
    case let .Leaf(headHash, remainder: headRemainder):
        let tailResult = parseSequence(headRemainder, tail)
        return combineSequenceLeaf(headHash, tailResult)
    }
}

func combineSequenceMatch(headText: String, headIndex: Int, tail: Result) -> Result {
    
    switch tail {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: tailMatch, index: tailIndex, remainder: tailRemainder):
        let sequenceRemainder = Remainder(text: tailRemainder.text, index: tailRemainder.index + tailIndex)
        return .Match(match: headText + tailMatch, index: headIndex, remainder: tailRemainder)
        
    case .Leaf:
        return tail
    }
}

func combineSequenceLeaf(headHash: [String: ResultLike], tail: Result) -> Result {

    switch tail {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: _, index: _, remainder: tailRemainder):
        return .Leaf(headHash, remainder: tailRemainder)
        
    case let .Leaf(tailHash, remainder: tailRemainder):
        return .Leaf(headHash + tailHash, remainder: tailRemainder)
    }
}

func +<K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    
    var map = Dictionary<K, V>()
    
    for (k, v) in left {
        map[k] = v
    }
    
    for (k, v) in right {
        map[k] = v
    }
    
    return map
}

func parseName(input: Remainder, name: String, sub: Syft) -> Result {

    let result = sub.parse(input)
    
    switch result {

    case .Failure:
        return .Failure

    case let .Match(match: _, index: _, remainder: remainder):
        return .Leaf([name: result], remainder: remainder)
        
    case let .Leaf(_, remainder: remainder):
        return .Leaf([name: result], remainder: remainder)
    }
}

func parseRepeat(input: Remainder, sub: Syft, #minimum: Int, #maximum: Int, #counter: Int) -> Result {

    if counter >= maximum {
        return Result.Match(match: "", index: 0, remainder: input)
    }
    let result = sub.parse(input)
    switch result {
    case let .Match(match: match, index: index, remainder: remainder):
        if counter < maximum {
            let tailResult = parseRepeat(remainder, sub, minimum: minimum, maximum: maximum, counter: counter + 1)
            return combineSequenceMatch(match, index, tailResult)
        } else {
            return result
        }
    default:
        return .Failure
    }
}
