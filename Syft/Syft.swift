public indirect enum Syft {

    case Str(String)
    case Sequence(Syft, Syft)
    case Name(String, Syft)
    case Repeat(Syft, minimum: Int, maximum: Int)
    
    public func parse(input: String) -> Result {
        return parse(Remainder(text: input, index: 0))
    }
    
    func parse(input: Remainder) -> Result {
        switch self {
            
        case let .Str(pattern):
            return parseStr(input, pattern: pattern)

        case let .Sequence(first, second):
            return parseSequence(input, subs: [first, second])
            
        case let .Name(name, sub):
            return parseName(input, name: name, sub: sub)
            
        case let .Repeat(sub, minimum, maximum):
            return parseRepeat(input, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: 0)
        }
    }
}

func parseStr(input: Remainder, pattern: String) -> Result {
    
    if (pattern.isEmpty || input.text.hasPrefix(pattern)) {
        
        let (headText, tailText) = input.text.splitAtIndex(pattern.endIndex)
        let tailIndex = input.index + headText.startIndex.distanceTo(headText.endIndex)
        let remainder = Remainder(text: tailText, index: tailIndex)
        
        return .Match(match: headText, index: input.index, remainder: remainder)
    }

    return .Failure
}

func parseSequence(input: Remainder, subs: [Syft]) -> Result {

    if let head = subs.head {
        return parseSequence(input, head: head, tail: subs.tail)
    } else {
        return .Match(match: "", index: input.index, remainder: input)
    }
}

func parseSequence(input: Remainder, head: Syft, tail: [Syft]) -> Result {

    switch head.parse(input) {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: headText, index: headIndex, remainder: headRemainder):
        let tailResult = parseSequence(headRemainder, subs: tail)
        return combineSequenceMatch(headText, headIndex: headIndex, tail: tailResult)
        
    case let .Hash(headHash, remainder: headRemainder):
        let tailResult = parseSequence(headRemainder, subs: tail)
        return combineSequenceHash(headHash, tail: tailResult)
        
    case .Array:
        return .Failure
    }
}

func combineSequenceMatch(headText: String, headIndex: Int, tail: Result) -> Result {
    
    switch tail {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: tailMatch, index: tailIndex, remainder: tailRemainder):
        _ = Remainder(text: tailRemainder.text, index: tailRemainder.index + tailIndex)
        return .Match(match: headText + tailMatch, index: headIndex, remainder: tailRemainder)
        
    case .Hash:
        return tail
        
    case .Array:
        return .Failure
    }
}

func combineSequenceHash(headHash: [String: Result], tail: Result) -> Result {

    switch tail {
        
    case .Failure:
        return .Failure
        
    case let .Match(match: _, index: _, remainder: tailRemainder):
        return .Hash(headHash, remainder: tailRemainder)
        
    case let .Hash(tailHash, remainder: tailRemainder):
        return .Hash(headHash + tailHash, remainder: tailRemainder)
        
    case .Array:
        return .Failure
    }
}

func parseName(input: Remainder, name: String, sub: Syft) -> Result {

    let result = sub.parse(input)
    
    switch result {

    case .Failure:
        return .Failure

    case let .Match(match: _, index: _, remainder: remainder):
        return .Hash([name: result], remainder: remainder)
        
    case let .Hash(_, remainder: remainder):
        return .Hash([name: result], remainder: remainder)
        
    case .Array:
        return .Failure
    }
}

func parseRepeat(input: Remainder, sub: Syft, minimum: Int, maximum: Int, matchesSoFar: Int) -> Result {
    let shouldAttemptAnotherMatch = matchesSoFar < maximum || maximum < 0
    
    if shouldAttemptAnotherMatch {
        let result = sub.parse(input)
        switch result {
            
        case .Failure:
            if minimum > 0 && matchesSoFar < minimum {
                return .Failure
            } else {
                return Result.Match(match: "", index: 0, remainder: input)
            }
            
        case let .Match(match: match, index: index, remainder: remainder):
            let tailResult = parseRepeat(remainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar + 1)
            
            switch tailResult {
                
            case .Failure:
                return matchesSoFar < minimum ? .Failure : result
                
            default:
                return combineSequenceMatch(match, headIndex: index, tail: tailResult)
            }
            
        case let .Hash(_, remainder: remainder):
            let tailResult = parseRepeat(remainder, sub: sub, minimum: minimum, maximum: maximum, matchesSoFar: matchesSoFar + 1)

            switch tailResult {
            case let .Match(match: _, index: _, remainder: tailRemainder):
                return Result.Array([result], remainder: tailRemainder)
            case .Array(var array, remainder: let remainder):
                array.insert(result, atIndex: 0)
                return Result.Array(array, remainder: remainder)
            case let .Hash(_, remainder: tailRemainder):
                return Result.Array([tailResult], remainder: tailRemainder)
            default:
                return .Failure
            }
            
        case .Array:
            return .Failure
        }
    } else {
        return Result.Match(match: "", index: 0, remainder: input)
    }
}
