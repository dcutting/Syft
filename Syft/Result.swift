public indirect enum Result: Equatable, CustomStringConvertible {
    
    case Failure
    case Match(match: String, index: Int, remainder: Remainder)
    case Hash([String: Result], remainder: Remainder)
    case Array([Result], remainder: Remainder)

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

func hashesEqual(lhsHash: [String: Result], rhsHash: [String: Result]) -> Bool {
    
    if lhsHash.count != rhsHash.count {
        return false
    }
    for (lhsName, lhsResult) in lhsHash {
        let rhsResult = rhsHash[lhsName]
        if lhsResult != rhsResult {
            return false
        }
    }
    return true
}

func arraysEqual(lhsArray: [Result], rhsArray: [Result]) -> Bool {
    if lhsArray.count != rhsArray.count {
        return false
    }
    var i = 0
    while i < lhsArray.count {
        let leftResult = lhsArray[i]
        let rightResult = rhsArray[i]
        if leftResult != rightResult {
            return false
        }
        i++
    }
    return true
}
