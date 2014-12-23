public protocol ResultLike {}

public enum Result: ResultLike, Equatable, Printable {
    
    case Failure
    case Match(match: String, index: Int, remainder: Remainder)
    case Leaf([String: ResultLike], remainder: Remainder)
    case Array([ResultLike], remainder: Remainder)

    public var description: String {

        switch self {
        
        case let .Failure:
            return "<failure>"
        
        case let .Match(match: match, index: index, remainder: remainder):
            return "\"\(match)\"@\(index)[\(remainder.text):\(remainder.index)]"
        
        case let .Leaf(hash, remainder: _):
            return hash.sortedDescription()
            
        case let .Array(array, remainder: remainder):
            return "\(array.sortedDescription())[\(remainder.text):\(remainder.index)]"
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

extension Array {
    
    func sortedDescription() -> String {
        
        let joined = ", ".join(self.map { "\($0)" }.sorted { $0 < $1 })
        
        return "[\(joined)]"
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {
    
    case let (.Failure, .Failure):
        return true
    
    case let (.Match(match: lhsMatch, index: lhsIndex, remainder: lhsRemainder), .Match(match: rhsMatch, index: rhsIndex, remainder: rhsRemainder)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex && lhsRemainder == rhsRemainder
    
    case let (.Leaf(lhsHash, remainder: lhsRemainder), .Leaf(rhsHash, remainder: rhsRemainder)):
        return hashesEqual(lhsHash, rhsHash) && lhsRemainder == rhsRemainder
        
    case let (.Array(lhsResults, remainder: lhsRemainder), .Array(rhsResults, remainder: rhsRemainder)):
        return arraysEqual(lhsResults, rhsResults) && lhsRemainder == rhsRemainder
    
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

func arraysEqual(lhsArray: [ResultLike], rhsArray: [ResultLike]) -> Bool {
    if countElements(lhsArray) != countElements(rhsArray) {
        return false
    }
    var i = 0
    while i < countElements(lhsArray) {
        let leftResult = lhsArray[i] as Result
        let rightResult = rhsArray[i] as Result
        if leftResult != rightResult {
            return false
        }
        i++
    }
    return true
}
