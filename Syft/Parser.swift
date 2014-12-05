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
        
        let patternLength = pattern.endIndex
        let (head, tail) = input.text.splitAtIndex(patternLength)
        
        return .Match(match: head, index: input.index, remainder: Remainder(text: tail, index: 0))
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

func parseSequence(remainder: Remainder, subs: [Syft]) -> Result {

    let input = remainder.text
    let currentIndex = remainder.index
    if let head = subs.head {
        switch head.parse(remainder) {
            
        case let .Match(match: headMatch, index: headIndex, remainder: headRemainder):
            let parsedTail = parseSequence(headRemainder, subs.tail)
            switch parsedTail {
            case let .Match(match: tailMatch, index: tailIndex, remainder: tailRemainder):
                return .Match(match: headMatch + tailMatch, index: 0, remainder: tailRemainder)
            case .Leaf:
                return parsedTail
            default:
                return .Failure
            }
        
        case let .Leaf(hash, remainder: headRemainder):
            let parsedTail = parseSequence(headRemainder, subs.tail)
            switch parsedTail {
            case let .Match(match: _, index: _, remainder: tailRemainder):
                return .Leaf(hash, remainder: tailRemainder)
            default:
                return .Failure
            }
            
        default:
            return .Failure
        }
    } else {
        return .Match(match: "", index: 0, remainder: Remainder(text: input, index: 0))
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

func parseName(input: Remainder, name: String, sub: Syft) -> Result {

    let result = sub.parse(input)
    
    switch result {

    case let .Match(match: _, index: _, remainder: remainder):
        return .Leaf([name: result], remainder: remainder)
        
    case let .Leaf(_, remainder: remainder):
        return .Leaf([name: result], remainder: remainder)
    
    case .Failure:
        return .Failure
    }
}
