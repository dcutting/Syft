public protocol ResultLike {}

public enum Result: ResultLike, Equatable, CustomStringConvertible {
    
    case Failure
    case Match(match: String, index: Int, remainder: Remainder)
    case Hash([String: ResultLike], remainder: Remainder)
    case Array([ResultLike], remainder: Remainder)

    public var description: String {

        switch self {
        
        case .Failure:
            return "<failure>"
        
        case let .Match(match: match, index: index, remainder: remainder):
            return "\"\(match)\"@\(index)[\(remainder.text):\(remainder.index)]"
        
        case let .Hash(hash, remainder: _):
            return hash.sortedDescription()
            
        case let .Array(array, remainder: remainder):
            return "\(array.sortedDescription())[\(remainder.text):\(remainder.index)]"
        }
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {
    
    case (.Failure, .Failure):
        return true
    
    case let (.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), .Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex && lhsRemainder == rhsRemainder
    
    case let (.Hash(lhsHash, remainder: lhsRemainder), .Hash(rhsHash, remainder: rhsRemainder)):
        return hashesEqual(lhsHash, rhsHash: rhsHash) && lhsRemainder == rhsRemainder
        
    case let (.Array(lhsResults, remainder: lhsRemainder), .Array(rhsResults, remainder: rhsRemainder)):
        return arraysEqual(lhsResults, rhsArray: rhsResults) && lhsRemainder == rhsRemainder
    
    default:
        return false
    }
}

func hashesEqual(lhsHash: [String: ResultLike], rhsHash: [String: ResultLike]) -> Bool {
    
    if lhsHash.count != rhsHash.count {
        return false
    }
    for (lhsName, lhsResultLike) in lhsHash {
        let lhsResult = lhsResultLike as! Result
        if let rhsResult = rhsHash[lhsName] as? Result {
            if lhsResult != rhsResult {
                return false
            }
        } else {
            return false
        }
    }
    return true
}

func arraysEqual(lhsArray: [ResultLike], rhsArray: [ResultLike]) -> Bool {
    if lhsArray.count != rhsArray.count {
        return false
    }
    var i = 0
    while i < lhsArray.count {
        let leftResult = lhsArray[i] as! Result
        let rightResult = rhsArray[i] as! Result
        if leftResult != rightResult {
            return false
        }
        i++
    }
    return true
}
