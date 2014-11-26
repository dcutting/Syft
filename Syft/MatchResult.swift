public enum MatchResult: Equatable {
    case Failure(remainder: String)
    case Success(remainder: String)
}

public func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    switch (lhs, rhs) {
    case let (MatchResult.Failure(remainder: lhsRemainder), MatchResult.Failure(remainder: rhsRemainder)):
        return lhsRemainder == rhsRemainder
    case let (MatchResult.Success(remainder: lhsRemainder), MatchResult.Success(remainder: rhsRemainder)):
        return lhsRemainder == rhsRemainder
    default:
        return false
    }
}
