public typealias ResultWithRemainder = (Result, Remainder)

public indirect enum Parser {

    case Str(String)
    case Sequence(Parser, Parser)
    case Name(String, Parser)
//    case Repeat(Parser, minimum: Int, maximum: Int)
    
    public func parse(input: String) -> ResultWithRemainder {
        return parse(Remainder(text: input, index: 0))
    }
    
    func parse(input: Remainder) -> ResultWithRemainder {
        switch self {
            
        case let .Str(pattern):
            return parseStr(input, pattern: pattern)

        case let .Sequence(first, second):
            return parseSequence(input, subs: [first, second])
            
        case let .Name(name, sub):
            return parseName(input, name: name, sub: sub)
            
//        case let .Repeat(sub, minimum, maximum):
//            return parseRepeat(input, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: 0)
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
        let (tailResult, tailRemainder) = parseSequence(headRemainder, subs: tail)
        return combineSequenceMatch(headText, headIndex: headIndex, tailResult: tailResult, tailRemainder: tailRemainder)
        
    case let (.Tagged(headTagged), headRemainder):
        let (tailResult, tailRemainder) = parseSequence(headRemainder, subs: tail)
        return combineSequenceTagged(headTagged, tailResult: tailResult, tailRemainder: tailRemainder)
        
    case (.Series, _):
        return (.Failure, input)
    }
}

func combineSequenceMatch(headText: String, headIndex: Int, tailResult: Result, tailRemainder: Remainder) -> ResultWithRemainder {
    
    switch (tailResult, tailRemainder) {
        
    case (.Failure, _):
        return (.Failure, tailRemainder)
        
    case let (.Match(match: tailMatch, index: tailIndex), tailRemainder):
        _ = Remainder(text: tailRemainder.text, index: tailRemainder.index + tailIndex)
        return (.Match(match: headText + tailMatch, index: headIndex), tailRemainder)
        
    case (.Tagged, _):
        return (tailResult, tailRemainder)
        
    case (.Series, _):
        return (.Failure, tailRemainder)
    }
}

func combineSequenceTagged(headTagged: [String: Result], tailResult: Result, tailRemainder: Remainder) -> ResultWithRemainder {

    switch (tailResult, tailRemainder) {
        
    case (.Failure, _):
        return (.Failure, tailRemainder)
        
    case let (.Match(match: _, index: _), tailRemainder):
        return (.Tagged(headTagged), tailRemainder)
        
    case let (.Tagged(tailTagged), tailRemainder):
        return (.Tagged(headTagged + tailTagged), tailRemainder)
        
    case (.Series, _):
        return (.Failure, tailRemainder)
    }
}

func parseName(input: Remainder, name: String, sub: Parser) -> ResultWithRemainder {

    let (result, remainder) = sub.parse(input)
    
    switch (result, remainder) {

    case (.Failure, _):
        return (.Failure, remainder)

    case let (.Match(match: _, index: _), remainder):
        return (.Tagged([name: result]), remainder)
        
    case let (.Tagged(_), remainder):
        return (.Tagged([name: result]), remainder)
        
    case (.Series, _):
        return (.Failure, remainder)
    }
}

//func parseRepeat(input: Remainder, sub: Parser, minimum: Int, maximum: Int, matchesSoFar: Int) -> ResultWithRemainder {
//    return (.Failure, input)
//    
//    let shouldAttemptAnotherMatch = matchesSoFar < maximum || maximum < 0
//    
//    if shouldAttemptAnotherMatch {
//        let result = sub.parse(input)
//        switch result {
//            
//        case .Failure:
//            if minimum > 0 && matchesSoFar < minimum {
//                return .Failure
//            } else {
//                return Result.Match(match: "", index: 0, remainder: input)
//            }
//            
//        case let .Match(match: match, index: index, remainder: remainder):
//            let tailResult = parseRepeat(remainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar + 1)
//            
//            switch tailResult {
//                
//            case .Failure:
//                return matchesSoFar < minimum ? .Failure : result
//                
//            default:
//                return combineSequenceMatch(match, headIndex: index, tail: tailResult)
//            }
//            
//        case let .Tagged(_, remainder: remainder):
//            let tailResult = parseRepeat(remainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar + 1)
//
//            switch tailResult {
//            case let .Match(match: _, index: _, remainder: tailRemainder):
//                return Result.Series([result], remainder: tailRemainder)
//            case .Series(var array, remainder: let remainder):
//                array.insert(result, atIndex: 0)
//                return Result.Series(array, remainder: remainder)
//            case let .Tagged(_, remainder: tailRemainder):
//                return Result.Series([tailResult], remainder: tailRemainder)
//            default:
//                return .Failure
//            }
//            
//        case .Series:
//            return .Failure
//        }
//    } else {
//        return Result.Match(match: "", index: 0, remainder: input)
//    }
//}
