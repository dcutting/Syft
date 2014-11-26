public protocol SyftLike {}

public enum Syft: SyftLike {
    case Match(String)
    case Sequence(SyftLike, SyftLike)
    
    public func parse(input: String) -> MatchResult {
        switch self {
            
        case let .Match(pattern):
            
            if (pattern.isEmpty || input.hasPrefix(pattern)) {
                let patternLength = pattern.endIndex
                let (head, tail) = input.splitAtIndex(patternLength)
                return MatchResult.Success(match: head, remainder: tail)
            }
            return MatchResult.Failure(remainder: input)

        case let .Sequence(first as Syft, second as Syft):
            
            let firstResult = first.parse(input)
            switch firstResult {
            case let MatchResult.Success(match: firstMatch, remainder: firstRemainder):
                let secondResult = second.parse(firstRemainder)
                switch secondResult {
                case let MatchResult.Success(match: secondMatch, remainder: secondRemainder):
                    let combinedMatch = firstMatch + secondMatch
                    return MatchResult.Success(match: combinedMatch, remainder: secondRemainder)
                default:
                    return MatchResult.Failure(remainder: input)
                }
            default:
                return MatchResult.Failure(remainder: input)
            }
            
        default:
            return MatchResult.Failure(remainder: input)
        }
    }
}

extension String {
    func splitAtIndex(index: String.Index) -> (String, String) {
        let head = self[self.startIndex..<index]
        let tail = self[index..<self.endIndex]
        return (head, tail)
    }
}
