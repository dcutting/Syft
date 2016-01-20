public typealias ResultWithRemainder = (Result, Remainder)

public indirect enum Result: Equatable, CustomStringConvertible {
    
    case Failure
    case Match(match: String, index: Int)
    case Tagged([String: Result])
    case Array([Result])
    
    public var description: String {

        switch self {
        
        case .Failure:
            return "<failure>"
        
        case let .Match(match: match, index: index):
            return "\"\(match)\"@\(index)"
        
        case let .Tagged(hash):
            return hash.sortedDescription()
            
        case let .Array(array):
            return "\(array.sortedDescription())"
        }
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {
    
    case (.Failure, .Failure):
        return true
    
    case let (.Match(match: lhsMatch, index: lhsIndex), .Match(match: rhsMatch, index: rhsIndex)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex
    
    case let (.Tagged(lhsHash), .Tagged(rhsHash)):
        return hashesEqual(lhsHash, rhsHash: rhsHash)
        
    case let (.Array(lhsResults), .Array(rhsResults)):
        return arraysEqual(lhsResults, rhsArray: rhsResults)
    
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
