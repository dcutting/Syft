public protocol ResultLike {}

public enum Result: ResultLike, Equatable, Printable {
    
    case Failure
    case Match(match: String, index: Int, remainder: Remainder)
    case Leaf([String: ResultLike], remainder: Remainder)

    public var description: String {

        switch self {
        
        case let .Failure:
            return "<failure>"
        
        case let .Match(match: match, index: index, remainder: _):
            return "\"\(match)\"@\(index)"
        
        case let .Leaf(hash, remainder: _):
            return hash.sortedDescription()
        }
    }
}

extension Dictionary {
    
    func sortedDescription() -> String {

        var pairs = Array<String>()
        for (key, value) in self {
            pairs.append("\(key): \(value)")
        }
        let joinedPairs = ", ".join(sorted(pairs))
        
        return "[\(joinedPairs)]"
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {
    
    case let (.Failure, .Failure):
        return true
    
    case let (.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), .Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex && lhsRemainder == rhsRemainder
    
    case let (.Leaf(lhsHash, remainder: lhsRemainder), .Leaf(rhsHash, remainder: rhsRemainder)):
        return hashesEqual(lhsHash, rhsHash)
    
    default:
        return false
    }
}

func hashesEqual(lhsHash: [String: ResultLike], rhsHash: [String: ResultLike]) -> Bool {
    
    if countElements(lhsHash) != countElements(rhsHash) {
        return false
    }
    for (lhsName, lhsMatch) in lhsHash {
        let lhsMatch2 = lhsMatch as Result
        if let rhsMatch = rhsHash[lhsName] as? Result {
            if lhsMatch2 != rhsMatch {
                return false
            }
        } else {
            return false
        }
    }
    return true
}
