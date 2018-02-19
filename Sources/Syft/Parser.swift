public typealias ResultWithRemainder = (Result, Remainder)

public protocol ParserProtocol {
    func parse(_ input: String) -> ResultWithRemainder
}

public indirect enum Parser: ParserProtocol {

    case any
    case str(String)
    case sequence(Parser, Parser)
    case tagged(String, Parser)
    case `defer`(Deferred)
    case `repeat`(Parser, minimum: Int, maximum: Int?)
    case maybe(Parser)
    case either(Parser, Parser)
    // TODO case absent

    public func parse(_ input: String) -> ResultWithRemainder {
        return parse(Remainder(text: input, index: 0))
    }

    func parse(_ input: Remainder) -> ResultWithRemainder {

        switch self {

        case .any:
            return parseAny(input)

        case let .str(pattern):
            return parseStr(input, pattern: pattern)

        case let .sequence(first, second):
            return parseSequence(input, first: first, second: second)

        case let .tagged(tag, sub):
            return parseTag(input, tag: tag, sub: sub)

        case let .defer(deferred):
            return parseDeferred(input, deferred: deferred)

        case let .repeat(sub, minimum, maximum):
            return parseRepeat(input, sub: sub, minimum: minimum, maximum: maximum, collapsible: false, matchesSoFar: 0, resultSoFar: nil, initialInput: input)

        case let .maybe(sub):
            return parseRepeat(input, sub: sub, minimum: 0, maximum: 1, collapsible: true, matchesSoFar: 0, resultSoFar: nil, initialInput: input)

        case let .either(first, second):
            return parseEither(input, first: first, second: second)
        }
    }

}

open class Deferred: ParserProtocol {
    public var parser: Parser?
    
    public init() {}

    public func parse(_ input: String) -> ResultWithRemainder {
        return parse(Remainder(text: input, index: 0))
    }

    func parse(_ input: Remainder) -> ResultWithRemainder {
        guard let parser = self.parser else { return (.failure, input) }
        return parser.parse(input)
    }

}

func parseAny(_ input: Remainder) -> ResultWithRemainder {

    guard input.text.endIndex > input.text.startIndex else { return (.failure, input) }
    let (headText, tailText) = input.text.split(at: 1)
    return (.match(match: headText, index: input.index), Remainder(text: tailText, index: input.index+1))
}

func parseStr(_ input: Remainder, pattern: String) -> ResultWithRemainder {

    if pattern.isEmpty || input.text.hasPrefix(pattern) {

        let (headText, tailText) = input.text.split(at: pattern.count)
        let tailIndex = input.index + headText.distance(from: headText.startIndex, to: headText.endIndex)
        let remainder = Remainder(text: tailText, index: tailIndex)

        return (.match(match: headText, index: input.index), remainder)
    }

    return (.failure, input)
}

func parseSequence(_ input: Remainder, first: Parser, second: Parser) -> ResultWithRemainder {

    let (firstResult, firstRemainder) = first.parse(input)

    switch firstResult {

    case .failure:
        return (.failure, input)

    default:
        let (secondResult, secondRemainder) = second.parse(firstRemainder)
        return (firstResult.combine(secondResult), secondRemainder)
    }
}

func parseTag(_ input: Remainder, tag: String, sub: Parser) -> ResultWithRemainder {

    let (result, remainder) = sub.parse(input)

    switch result {

    case .failure:
        return (.failure, input)

    default:
        return (.tagged([tag: result]), remainder)
    }
}

func parseDeferred(_ input: Remainder, deferred: Deferred) -> ResultWithRemainder {
    return deferred.parse(input)
}

func parseRepeat(_ input: Remainder, sub: Parser, minimum: Int, maximum: Int?, collapsible: Bool, matchesSoFar: Int, resultSoFar: Result?, initialInput: Remainder) -> ResultWithRemainder {

    if let maximum = maximum {
        if matchesSoFar >= maximum {
            if let resultSoFar = resultSoFar {
                return (resultSoFar, input)
            }
            if collapsible {
                return (.match(match: "", index: 0), input)
            }
            return (.series([]), input)
        }
    }

    let (headResult, headRemainder) = sub.parse(input)
    switch headResult {
    case .failure:
        if matchesSoFar < minimum {
            return (.failure, initialInput)
        } else {
            if let resultSoFar = resultSoFar {
                return (resultSoFar, input)
            }
            if collapsible {
                return (.match(match: "", index: 0), input)
            }
            return (.series([]), input)
        }
    default:
        if let resultSoFar = resultSoFar {
            let combinedResult = resultSoFar.combine(headResult)
            return parseRepeat(headRemainder, sub: sub, minimum: minimum, maximum: maximum, collapsible: collapsible, matchesSoFar: matchesSoFar+1, resultSoFar: combinedResult, initialInput: initialInput)
        } else {
            let combinedResult = prepareInitialResultForRepeat(headResult, collapsible: collapsible)
            return parseRepeat(headRemainder, sub: sub, minimum: minimum, maximum: maximum, collapsible: collapsible, matchesSoFar: matchesSoFar+1, resultSoFar: combinedResult, initialInput: initialInput)
        }
    }
}

func prepareInitialResultForRepeat(_ result: Result, collapsible: Bool) -> Result {

    switch result {

    case .tagged:
        if collapsible {
            return .maybe(result)
        } else {
            return .series([result])
        }

    default:
        return result
    }
}

func parseEither(_ input: Remainder, first: Parser, second: Parser) -> ResultWithRemainder {

    let firstResultWithRemainder = first.parse(input)

    switch firstResultWithRemainder {

    case (.failure, _):
        return second.parse(input)

    default:
        return firstResultWithRemainder
    }
}
