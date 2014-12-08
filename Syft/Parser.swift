public protocol SyftLike {}

public enum Syft: SyftLike {

    case Match(String)
    case Sequence(SyftLike, SyftLike)
    case Name(String, SyftLike)
    
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
        switch head.parse(input) {
            
        case .Failure:
            return .Failure
            
        case let .Match(match: headMatch, index: _, remainder: headRemainder):
            let parsedTail = parseSequence(headRemainder, subs.tail)
            switch parsedTail {
            case let .Match(match: tailMatch, index: tailIndex, remainder: tailRemainder):
                let sequenceRemainder = Remainder(text: tailRemainder.text, index: tailRemainder.index + tailIndex)
                return .Match(match: headMatch + tailMatch, index: input.index, remainder: tailRemainder)
            case .Leaf:
                return parsedTail
            default:
                return .Failure
            }
        
        case let .Leaf(headHash, remainder: headRemainder):
            let parsedTail = parseSequence(headRemainder, subs.tail)
            switch parsedTail {
            case let .Match(match: _, index: _, remainder: tailRemainder):
                return .Leaf(headHash, remainder: tailRemainder)
            case let .Leaf(tailHash, remainder: tailRemainder):
                return .Leaf(headHash + tailHash, remainder: tailRemainder)
            default:
                return .Failure
            }
        }
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
