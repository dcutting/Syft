public indirect enum Result: Equatable, CustomStringConvertible {

    case failure
    case match(match: String, index: Int)
    case tagged([String: Result])
    case series([Result])

    public var description: String {

        switch self {

        case .failure:
            return "<failure>"

        case let .match(match: match, index: index):
            return "\"\(match)\"@\(index)"

        case let .tagged(tagged):
            return tagged.sortedDescription()

        case let .series(series):
            return "\(series)"
        }
    }

    func combine(_ secondary: Result) -> Result {

        switch (self, secondary) {

        case let (.match(match: selfText, index: selfIndex), .match(match: secondaryText, index: _)):
            return .match(match: selfText + secondaryText, index: selfIndex)

        case (.match, .tagged):
            return secondary

        case (.tagged, .match):
            return self

        case let (.tagged(selfTagged), .tagged(secondaryTagged)):
            return .tagged(selfTagged + secondaryTagged)

        case let (.series(selfSeries), .tagged):
            return .series(selfSeries + [secondary])

        case let (.tagged, .series(secondarySeries)):
            return .series([self] + secondarySeries)

        default:
            return .failure
        }
    }

}

public func == (lhs: Result, rhs: Result) -> Bool {

    switch (lhs, rhs) {

    case (.failure, .failure):
        return true

    case let (.match(match: lhsMatch, index: lhsIndex), .match(match: rhsMatch, index: rhsIndex)):
        return lhsMatch == rhsMatch && lhsIndex == rhsIndex

    case let (.tagged(lhsTagged), .tagged(rhsTagged)):
        return taggedEqual(lhsTagged, rhsTagged)

    case let (.series(lhsResults), .series(rhsResults)):
        return seriesEqual(lhsResults, rhsResults)

    default:
        return false
    }
}

func taggedEqual(_ lhsTagged: [String: Result], _ rhsTagged: [String: Result]) -> Bool {

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

func seriesEqual(_ lhsSeries: [Result], _ rhsSeries: [Result]) -> Bool {
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
        i += 1
    }
    return true
}