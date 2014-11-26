public enum MatchResult: Equatable {
    case Failure(remainder: String)
    case Success(match: String, remainder: String)
}

public func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    switch (lhs, rhs) {
    case let (MatchResult.Failure(remainder: lhsRemainder), MatchResult.Failure(remainder: rhsRemainder)):
        return lhsRemainder == rhsRemainder
    case let (MatchResult.Success(match: lhsMatch, remainder: lhsRemainder), MatchResult.Success(match: rhsMatch, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsRemainder == rhsRemainder
    default:
        return false
    }
}
