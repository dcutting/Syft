public protocol SyftLike {}

public enum Syft: SyftLike {

    case Match(String)
    case Sequence(SyftLike, SyftLike)
    case Name(String, SyftLike)
    
    public func parse(input: String) -> Result {
        switch self {
            
        case let .Match(pattern):
            return parseMatch(input, pattern)

        case let .Sequence(first as Syft, second as Syft):
            return parseSequence(input, first, second)
            
        case let .Name(name, sub as Syft):
            return parseName(input, name, sub)
            
        default:
            return .Failure
        }
    }
}

func parseMatch(input: String, pattern: String) -> Result {
    
    if (pattern.isEmpty || input.hasPrefix(pattern)) {
        
        let patternLength = pattern.endIndex
        let (head, tail) = input.splitAtIndex(patternLength)
        
        return .Match(match: head, index: 0, remainder: tail)
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

func parseSequence(input: String, first: Syft, second: Syft) -> Result {

    switch first.parse(input) {
    
    case let .Match(match: firstMatch, index: 0, remainder: firstRemainder):
        return parseSubsequence(input, firstRemainder, firstMatch, second)
        
    default:
        return .Failure
    }
}

func parseSubsequence(input: String, firstRemainder: String, firstMatch: String, second: Syft) -> Result {

    switch second.parse(firstRemainder) {
        
    case let .Match(match: secondMatch, index: 0, remainder: secondRemainder):
        
        let combinedMatch = firstMatch + secondMatch
        
        return .Match(match: combinedMatch, index: 0, remainder: secondRemainder)
        
    default:
        return .Failure
    }
}

func parseName(input: String, name: String, sub: Syft) -> Result {

    let result = sub.parse(input)
    
    switch result {

    case .Failure:
        return .Failure
    
    default:
        return Result.Leaf([name: result])
    }
}
