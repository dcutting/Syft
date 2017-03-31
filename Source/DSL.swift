infix operator >>> : ConcatPrecendence

precedencegroup ConcatPrecendence {
    associativity: left
    higherThan: AdditionPrecedence
}

func >>> (first: Parser, second: Parser) -> Parser {
    return Parser.sequence(first, second)
}

func >>> (first: Parser, second: Deferred) -> Parser {
    return Parser.sequence(first, Parser.defer(second))
}

func >>> (first: Deferred, second: Parser) -> Parser {
    return Parser.sequence(Parser.defer(first), second)
}

func >>> (first: Deferred, second: Deferred) -> Parser {
    return Parser.sequence(Parser.defer(first), Parser.defer(second))
}

func | (first: Parser, second: Parser) -> Parser {
    return Parser.either(first, second)
}

func | (first: Parser, second: Deferred) -> Parser {
    return Parser.either(first, Parser.defer(second))
}

func | (first: Deferred, second: Parser) -> Parser {
    return Parser.either(Parser.defer(first), second)
}

func | (first: Deferred, second: Deferred) -> Parser {
    return Parser.either(Parser.defer(first), Parser.defer(second))
}

protocol ParserDSL {
    func recur() -> Parser
    func recur(_ minimum: Int) -> Parser
    func recur(_ minimum: Int, _ maximum: Int?) -> Parser
    var some: Parser { get }
    var maybe: Parser { get }
    func tag(_ tag: String) -> Parser
}

extension Parser: ParserDSL {

    func recur() -> Parser {
        return recur(0, nil)
    }

    func recur(_ minimum: Int) -> Parser {
        return recur(minimum, nil)
    }

    func recur(_ minimum: Int, _ maximum: Int?) -> Parser {
        return Parser.repeat(self, minimum: minimum, maximum: maximum)
    }

    var some: Parser {
        get {
            return recur(1)
        }
    }

    var maybe: Parser {
        get {
            return recur(0, 1)
        }
    }

    func tag(_ tag: String) -> Parser {
        return Parser.tagged(tag, self)
    }

}

extension Deferred: ParserDSL {

    fileprivate func wrap() -> Parser {
        return Parser.defer(self)
    }

    func recur() -> Parser {
        return wrap().recur()
    }

    func recur(_ minimum: Int) -> Parser {
        return wrap().recur(minimum)
    }

    func recur(_ minimum: Int, _ maximum: Int?) -> Parser {
        return wrap().recur(minimum, maximum)
    }

    var some: Parser {
        get {
            return wrap().some
        }
    }

    var maybe: Parser {
        get {
            return wrap().maybe
        }
    }

    func tag(_ tag: String) -> Parser {
        return wrap().tag(tag)
    }

}

extension CountableClosedRange {
    var match: Parser {
        get {
            return makeEither(self.map { String(describing: $0) })
        }
    }
}

extension Array {
    var match: Parser {
        get {
            return makeEither(self.map { String(describing: $0) })
        }
    }
}

extension String {
    var match: Parser {
        get {
            return makeEither(self.characters.map { String($0) })
        }
    }
}

func makeEither(_ input: [String]) -> Parser {
    var parser: Parser = Parser.str(input.head!)
    for s in input.tail {
        parser = Parser.either(parser, Parser.str(s))
    }
    return parser
}

let any = Parser.any

func str(_ str: String) -> Parser {
    return Parser.str(str)
}
