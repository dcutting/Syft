public protocol ResultLike {}

public enum Result: ResultLike, Equatable, Printable {
    
    case Failure
    case Match(match: String, index: Int, remainder: String)
    case Leaf([String: ResultLike])

    public var description: String {

        switch self {
        
        case let .Failure(remainder: remainder):
            return "<failure>"
        
        case let .Match(match: match, index: index, remainder: remainder):
            return "\"\(match)\"@\(index)"
        
        case let .Leaf(hash):
            return hash.sortedDescription()
        
        default:
            return "<unknown>"
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
    
    case let (Result.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), Result.Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsRemainder == rhsRemainder && lhsIndex == rhsIndex
    
    case let (Result.Leaf(lhsHash), Result.Leaf(rhsHash)):
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
