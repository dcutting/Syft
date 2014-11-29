public protocol MatchResultLike {}

public enum MatchResult: MatchResultLike, Equatable {
    case Failure(remainder: String)
    case Match(match: String, index: Int, remainder: String)
    case Leaf(name: String, match: MatchResultLike)
}

public func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    switch (lhs, rhs) {
    case let (MatchResult.Failure(remainder: lhsRemainder), MatchResult.Failure(remainder: rhsRemainder)):
        return lhsRemainder == rhsRemainder
    case let (MatchResult.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), MatchResult.Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsRemainder == rhsRemainder && lhsIndex == rhsIndex
    case let (MatchResult.Leaf(name: lhsName, match: lhsMatch), MatchResult.Leaf(name: rhsName, match: rhsMatch)):
        return true
    default:
        return false
    }
}
