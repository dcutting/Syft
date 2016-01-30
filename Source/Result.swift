public indirect enum Result: Equatable, CustomStringConvertible {
    
    case Failure
    case Match(match: String, index: Int)
    case Tagged([String: Result])
    case Series([Result])
    
    public var description: String {

        switch self {
        
        case .Failure:
            return "<failure>"
        
        case let .Match(match: match, index: index):
            return "\"\(match)\"@\(index)"
        
        case let .Tagged(tagged):
            return tagged.sortedDescription()
            
        case let .Series(series):
            return "\(series)"
        }
    }
    
    func combine(secondary: Result) -> Result {
        
        switch (self, secondary) {
            
        case let (.Match(match: selfText, index: selfIndex), .Match(match: secondaryText, index: _)):
            return .Match(match: selfText + secondaryText, index: selfIndex)

        case (.Match, .Tagged):
            return secondary
        
        case (.Tagged, .Match):
            return self
        
        case let (.Tagged(selfTagged), .Tagged(secondaryTagged)):
            return .Tagged(selfTagged + secondaryTagged)

        case let (.Series(selfSeries), .Tagged):
            return .Series(selfSeries + [secondary])
            
        case let (.Tagged, .Series(secondarySeries)):
            return .Series([self] + secondarySeries)
            
        default:
            return .Failure
        }
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {
    
    case (.Failure, .Failure):
        return true
    
    case let (.Match(match: lhsMatch, index: lhsIndex), .Match(match: rhsMatch, index: rhsIndex)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex
    
    case let (.Tagged(lhsTagged), .Tagged(rhsTagged)):
        return taggedEqual(lhsTagged, rhsTagged)
        
    case let (.Series(lhsResults), .Series(rhsResults)):
        return seriesEqual(lhsResults, rhsResults)
    
    default:
        return false
    }
}

func taggedEqual(lhsTagged: [String: Result], _ rhsTagged: [String: Result]) -> Bool {
    
    if lhsTagged.count != rhsTagged.count {
        return false
    }
    for (lhsName, lhsResult) in lhsTagged {
        let rhsResult = rhsTagged[lhsName]
        if lhsResult != rhsResult {
            return false
        }
    }
    return true
}

func seriesEqual(lhsSeries: [Result], _ rhsSeries: [Result]) -> Bool {
    if lhsSeries.count != rhsSeries.count {
        return false
    }
    var i = 0
    while i < lhsSeries.count {
        let leftResult = lhsSeries[i]
        let rightResult = rhsSeries[i]
        if leftResult != rightResult {
            return false
        }
        i++
    }
    return true
}
