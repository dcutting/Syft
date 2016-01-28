public typealias ResultWithRemainder = (Result, Remainder)

public indirect enum Parser {
    
    case Str(String)
    case Sequence(Parser, Parser)
    case Tag(String, Parser)
    case Deferred(DeferredParser)
    case Repeat(Parser, minimum: Int, maximum: Int?)
    case OneOf(Parser, Parser)
    
    public func parse(input: String) -> ResultWithRemainder {
        return parse(Remainder(text: input, index: 0))
    }
    
    func parse(input: Remainder) -> ResultWithRemainder {
        switch self {
            
        case let .Str(pattern):
            return parseStr(input, pattern: pattern)

        case let .Sequence(first, second):
            return parseSequence(input, subs: [first, second])
            
        case let .Tag(tag, sub):
            return parseTag(input, tag: tag, sub: sub)
            
        case let .Deferred(deferred):
            return parseDeferred(input, deferred: deferred)
            
        case let .Repeat(sub, minimum, maximum):
            return parseRepeat(input, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: 0, resultSoFar: nil, initialInput: input)
            
        case .OneOf:
            return (.Failure, input)
        }
    }
}

public class DeferredParser {
    var name: String
    var parser: Parser?
    
    init(name: String) {
        self.name = name
    }
    
    func parse(input: String) -> ResultWithRemainder {
        return parse(Remainder(text: input, index: 0))
    }
    
    func parse(input: Remainder) -> ResultWithRemainder {
        guard let parser = self.parser else { return (.Failure, input) }
        return parser.parse(input)
    }
}

func parseStr(input: Remainder, pattern: String) -> ResultWithRemainder {
    
    if (pattern.isEmpty || input.text.hasPrefix(pattern)) {
        
        let (headText, tailText) = input.text.splitAtIndex(pattern.endIndex)
        let tailIndex = input.index + headText.startIndex.distanceTo(headText.endIndex)
        let remainder = Remainder(text: tailText, index: tailIndex)
        
        return (.Match(match: headText, index: input.index), remainder)
    }

    return (.Failure, input)
}

func parseSequence(input: Remainder, subs: [Parser]) -> ResultWithRemainder {

    if let head = subs.head {
        return parseSequence(input, head: head, tail: subs.tail)
    }
    return (.Match(match: "", index: input.index), input)
}

func parseSequence(input: Remainder, head: Parser, tail: [Parser]) -> ResultWithRemainder {

    let (headResult, headRemainder) = head.parse(input)

    switch headResult {
    
    case .Failure:
        return (.Failure, input)
    
    default:
        let (tailResult, tailRemainder) = parseSequence(headRemainder, subs: tail)
        return (headResult.combine(tailResult), tailRemainder)
    }
}

func parseTag(input: Remainder, tag: String, sub: Parser) -> ResultWithRemainder {

    let (result, remainder) = sub.parse(input)
    
    switch result {

    case .Failure:
        return (.Failure, input)

    default:
        return (.Tagged([tag: result]), remainder)
    }
}

func parseDeferred(input: Remainder, deferred: DeferredParser) -> ResultWithRemainder {
    return deferred.parse(input)
}

func parseRepeat(input: Remainder, sub: Parser, minimum: Int, maximum: Int?, matchesSoFar: Int, resultSoFar: Result?, initialInput: Remainder) -> ResultWithRemainder {

    if let maximum = maximum {
        if matchesSoFar >= maximum {
            if let resultSoFar = resultSoFar {
                return (resultSoFar, input)
            }
            return (Result.Match(match: "", index: input.index), input)
        }
    }
    
    let (headResult, headRemainder) = sub.parse(input)
    switch headResult {
    case .Failure:
        if matchesSoFar < minimum {
            return (.Failure, initialInput)
        } else {
            if let resultSoFar = resultSoFar {
                return (resultSoFar, input)
            }
            return (Result.Match(match: "", index: input.index), input)
        }
    default:
        if let resultSoFar = resultSoFar {
            let combinedResult = resultSoFar.combine(headResult)
            return parseRepeat(headRemainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar+1, resultSoFar: combinedResult, initialInput: initialInput)
        } else {
            let combinedResult = prepareInitialResultForRepeat(headResult)
            return parseRepeat(headRemainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar+1, resultSoFar: combinedResult, initialInput: initialInput)
        }
    }
}

func prepareInitialResultForRepeat(result: Result) -> Result {
    switch result {

    case .Tagged:
        return .Series([result])
    
    default:
        return result
    }
}
