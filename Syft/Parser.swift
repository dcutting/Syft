public typealias ResultWithRemainder = (Result, Remainder)

public typealias ParserRef = String

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
    } else {
        return (.Match(match: "", index: input.index), input)
    }
}

func parseSequence(input: Remainder, head: Parser, tail: [Parser]) -> ResultWithRemainder {

    switch head.parse(input) {
    
    case (.Failure, _):
        return (.Failure, input)
        
    case let (.Match(match: headText, index: headIndex), headRemainder):
        let parsedTail = parseSequence(headRemainder, subs: tail)
        return combineSequenceMatch(headText, headIndex: headIndex, parsedTail: parsedTail)
        
    case let (.Tagged(headTagged), headRemainder):
        let parsedTail = parseSequence(headRemainder, subs: tail)
        return combineSequenceTagged(headTagged, parsedTail: parsedTail)
        
    case (.Series, _):
        return (.Failure, input)
    }
}

func combineSequenceMatch(headText: String, headIndex: Int, parsedTail: ResultWithRemainder) -> ResultWithRemainder {
    
    switch parsedTail {
        
    case let (.Failure, tailRemainder):
        return (.Failure, tailRemainder)
        
    case let (.Match(match: tailMatch, index: tailIndex), tailRemainder):
        _ = Remainder(text: tailRemainder.text, index: tailRemainder.index + tailIndex)
        return (.Match(match: headText + tailMatch, index: headIndex), tailRemainder)
        
    case (.Tagged, _):
        return parsedTail
        
    case let (.Series, tailRemainder):
        return (.Failure, tailRemainder)
    }
}

func combineSequenceTagged(headTagged: [String: Result], parsedTail: ResultWithRemainder) -> ResultWithRemainder {

    switch parsedTail {
        
    case let (.Failure, tailRemainder):
        return (.Failure, tailRemainder)
        
    case let (.Match(match: _, index: _), tailRemainder):
        return (.Tagged(headTagged), tailRemainder)
        
    case let (.Tagged(tailTagged), tailRemainder):
        return (.Tagged(headTagged + tailTagged), tailRemainder)
        
    case let (.Series, tailRemainder):
        return (.Failure, tailRemainder)
    }
}

func parseTag(input: Remainder, tag: String, sub: Parser) -> ResultWithRemainder {

    let (result, remainder) = sub.parse(input)
    
    switch (result, remainder) {

    case (.Failure, _):
        return (.Failure, remainder)

    case let (.Match, remainder):
        return (.Tagged([tag: result]), remainder)
        
    case let (.Tagged, remainder):
        return (.Tagged([tag: result]), remainder)
        
    case (.Series, _):
        return (.Failure, remainder)
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
            let combinedResult = headResult
            return parseRepeat(headRemainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar+1, resultSoFar: combinedResult, initialInput: initialInput)
        }
    }
}
