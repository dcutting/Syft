public protocol SyftLike {}

public enum Syft: SyftLike {

    case Match(String)
    case Sequence(SyftLike, SyftLike)
    
    public func parse(input: String) -> MatchResult {
        switch self {
            
        case let .Match(pattern):
            return parseMatch(input, pattern)

        case let .Sequence(first as Syft, second as Syft):
            return parseSequence(input, first, second)
            
        default:
            return MatchResult.Failure(remainder: input)
        }
    }
}

func parseMatch(input: String, pattern: String) -> MatchResult {
    
    if (pattern.isEmpty || input.hasPrefix(pattern)) {
        
        let patternLength = pattern.endIndex
        let (head, tail) = input.splitAtIndex(patternLength)
        
        return MatchResult.Success(match: head, remainder: tail)
    }

    return MatchResult.Failure(remainder: input)
}

extension String {

    func splitAtIndex(index: String.Index) -> (String, String) {
        
        let head = self[self.startIndex..<index]
        let tail = self[index..<self.endIndex]
        
        return (head, tail)
    }
}

func parseSequence(input: String, first: Syft, second: Syft) -> MatchResult {

    switch first.parse(input) {
    
    case let MatchResult.Success(match: firstMatch, remainder: firstRemainder):

        switch second.parse(firstRemainder) {
        
        case let MatchResult.Success(match: secondMatch, remainder: secondRemainder):
            
            let combinedMatch = firstMatch + secondMatch
            
            return MatchResult.Success(match: combinedMatch, remainder: secondRemainder)
        
        default:
            return MatchResult.Failure(remainder: input)
        }

    default:
        return MatchResult.Failure(remainder: input)
    }
}
