public protocol MatchResultLike {}

public enum MatchResult: MatchResultLike, Equatable, Printable {
    case Failure
    case Match(match: String, index: Int, remainder: String)
    case Leaf([String: MatchResultLike])

    public var description: String {
        switch self {
        case let .Failure(remainder: remainder):
            return "<failure>"
        case let .Match(match: match, index: index, remainder: remainder):
            return "\"\(match)\"@\(index)"
        case let .Leaf(hash):
            var str = ""
            for (name, match) in hash {
                str += "{\"\(name)\": \(match)}"
            }
            return str
        default:
            return "<unknown>"
        }
    }
}

public func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    switch (lhs, rhs) {
    case let (.Failure, .Failure):
        return true
    case let (MatchResult.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), MatchResult.Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsRemainder == rhsRemainder && lhsIndex == rhsIndex
    case let (MatchResult.Leaf(lhsHash), MatchResult.Leaf(rhsHash)):
        return hashesEqual(lhsHash, rhsHash)
    default:
        return false
    }
}

func hashesEqual(lhsHash: [String: MatchResultLike], rhsHash: [String: MatchResultLike]) -> Bool {
    if countElements(lhsHash) != countElements(rhsHash) {
        return false
    }
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