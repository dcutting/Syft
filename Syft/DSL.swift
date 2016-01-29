infix operator >>> { associativity left precedence 180 }
func >>>(first: Parser, second: Parser) -> Parser {
    return Parser.Sequence(first, second)
}

func >>>(first: Parser, second: Deferred) -> Parser {
    return Parser.Sequence(first, Parser.Defer(second))
}

func >>>(first: Deferred, second: Parser) -> Parser {
    return Parser.Sequence(Parser.Defer(first), second)
}

func >>>(first: Deferred, second: Deferred) -> Parser {
    return Parser.Sequence(Parser.Defer(first), Parser.Defer(second))
}

func |(first: Parser, second: Parser) -> Parser {
    return Parser.Either(first, second)
}

func |(first: Parser, second: Deferred) -> Parser {
    return Parser.Either(first, Parser.Defer(second))
}

func |(first: Deferred, second: Parser) -> Parser {
    return Parser.Either(Parser.Defer(first), second)
}

func |(first: Deferred, second: Deferred) -> Parser {
    return Parser.Either(Parser.Defer(first), Parser.Defer(second))
}

protocol ParserDSL {
    func recur() -> Parser
    func recur(minimum: Int) -> Parser
    func recur(minimum: Int, _ maximum: Int?) -> Parser
    var some: Parser { get }
    var maybe: Parser { get }
    func tag(tag: String) -> Parser
}

extension Parser: ParserDSL {
    func recur() -> Parser {
        return recur(0, nil)
    }
    
    func recur(minimum: Int) -> Parser {
        return recur(minimum, nil)
    }
    
    func recur(minimum: Int, _ maximum: Int?) -> Parser {
        return Parser.Repeat(self, minimum: minimum, maximum: maximum)
    }
    
    var some: Parser {
        get { return recur(1) }
    }
    
    var maybe: Parser {
        get { return recur(0, 1) }
    }
    
    func tag(tag: String) -> Parser {
        return Parser.Tag(tag, self)
    }
}

extension Deferred: ParserDSL {
    private func wrap() -> Parser {
        return Parser.Defer(self)
    }
    
    func recur() -> Parser {
        return wrap().recur()
    }
    
    func recur(minimum: Int) -> Parser {
        return wrap().recur(minimum)
    }
    
    func recur(minimum: Int, _ maximum: Int?) -> Parser {
        return wrap().recur(minimum, maximum)
    }
    
    var some: Parser {
        get { return wrap().some }
    }
    
    var maybe: Parser {
        get { return wrap().maybe }
    }
    
    func tag(tag: String) -> Parser {
        return wrap().tag(tag)
    }
}

extension Range {
    var any: Parser {
        get { return makeEither(self.map{String($0)}) }
    }
}

extension Array {
    var any: Parser {
        get { return makeEither(self.map{String($0)}) }
    }
}

extension String {
    var any: Parser {
        get { return makeEither(self.characters.map{String($0)}) }
    }
}

func makeEither(input: [String]) -> Parser {
    var parser: Parser = Parser.Str(input.head!)
    for s in input.tail {
        parser = Parser.Either(parser, Parser.Str(s))
    }
    return parser
}
