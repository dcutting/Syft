public protocol MatchResultLike {}

public enum MatchResult: MatchResultLike, Equatable, Printable {
    case Failure(remainder: String)
    case Match(match: String, index: Int, remainder: String)
    case Leaf([String: MatchResultLike])

    public var description: String {
        switch self {
        case let .Failure(remainder: remainder):
            return "F(\(remainder))"
        case let .Match(match: match, index: index, remainder: remainder):
            return "\"\(match)\"@\(index)"
        case let .Leaf(hash):
            var str = ""
            for (name, match) in hash {
                str += "{\"\(name)\": \(match)}"
            }
            return str
        default:
            return "<Unknown>"
        }
    }
}

public func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    switch (lhs, rhs) {
    case let (MatchResult.Failure(remainder: lhsRemainder), MatchResult.Failure(remainder: rhsRemainder)):
        return lhsRemainder == rhsRemainder
    case let (MatchResult.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), MatchResult.Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsRemainder == rhsRemainder && lhsIndex == rhsIndex
    case let (MatchResult.Leaf(lhsHash), MatchResult.Leaf(rhsHash)):
        return hashesEqual(lhsHash, rhsHash)
    default:
        return false
    }
}

func hashesEqual(lhsHash: [String: MatchResultLike], rhsHash: [String: MatchResultLike]) -> Bool {
    for (lhsName, lhsMatch) in lhsHash {
        let lhsMatch2 = lhsMatch as MatchResult
        if let rhsMatch = rhsHash[lhsName] as? MatchResult {
            if lhsMatch2 != rhsMatch {
                return false
            }
        } else {
            return false
        }
    }
    return true

}