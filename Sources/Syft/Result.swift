public indirect enum Result: Equatable, CustomStringConvertible {

    case failure
    case match(match: String, index: Int)
    case tagged([String: Result])
    case series([Result])
    case maybe(Result)

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

        case let .maybe(maybe):
            return "\(maybe)?"
        }
    }

    func combineSeriesOfTags(series: [Result], tagged: [String: Result]) -> Result {
        let seriesTagged: [[String: Result]] = series.compactMap { (item: Result) -> [String: Result]? in
            if case let .tagged(tagged) = item {
                return tagged
            }
            return nil
        }
        let combined = [tagged] + seriesTagged
        let combinedTagged = combined.reduce(into: [:]) { (counts, next: [String: Result]) in
            next.keys.forEach { k in
                counts[k] = next[k]
            }
        }
        let combinedSeries = Result.series([Result.tagged(combinedTagged)])
        return combinedSeries
    }

    func combine(_ secondary: Result) -> Result {

        switch (self, secondary) {

        case let (.match(match: selfText, index: selfIndex), .match(match: secondaryText, index: _)):
            return .match(match: selfText + secondaryText, index: selfIndex)
        case (.match, .tagged),
             (.match, .series),
             (.match, .maybe):
            return secondary
        case (.match, .failure):
            return .failure

        case (.tagged, .match):
            return self
        case let (.tagged(selfTagged), .tagged(secondaryTagged)):
            return .tagged(selfTagged + secondaryTagged)
        case let (.tagged(_), .series(secondarySeries)):
//            let combinedSeries = combineSeriesOfTags(series: secondarySeries, tagged: selfTagged)
//            return combinedSeries
            return .series([self] + secondarySeries)
        case let (.tagged, .maybe(secondaryResult)):
            // https://github.com/kschiess/parslet/blob/master/lib/parslet/atoms/can_flatten.rb#L38
            return self.combine(secondaryResult)
        case (.tagged, .failure):
            return .failure

        case (.series, .match):
            return secondary    // NOTE: not sure this is right for non-empty self series...
        case let (.series(selfSeries), .tagged(_)):
//            let combinedSeries = combineSeriesOfTags(series: selfSeries, tagged: secondaryTagged)
//            return combinedSeries
            return .series(selfSeries + [secondary])
        case let (.series(selfSeries), .series(secondarySeries)):
            return .series(selfSeries + secondarySeries)
        case let (.series, .maybe(secondaryResult)):
            return self.combine(secondaryResult)
        case (.series, .failure):
            return .failure

        case (.maybe, .match):
            return self
        case let (.maybe(firstResult), .tagged),
             let (.maybe(firstResult), .series),
             let (.maybe(firstResult), .maybe):
            return firstResult.combine(secondary)
        case (.maybe, .failure):
            return .failure

        case (.failure, .match),
             (.failure, .tagged),
             (.failure, .series),
             (.failure, .maybe),
             (.failure, .failure):
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
