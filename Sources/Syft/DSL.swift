infix operator >>> : ConcatPrecendence

precedencegroup ConcatPrecendence {
    associativity: left
    higherThan: AdditionPrecedence
}

public func >>> (first: Parser, second: Parser) -> Parser {
    return Parser.sequence(first, second)
}

public func >>> (first: Parser, second: Deferred) -> Parser {
    return Parser.sequence(first, Parser.defer(second))
}

public func >>> (first: Deferred, second: Parser) -> Parser {
    return Parser.sequence(Parser.defer(first), second)
}

public func >>> (first: Deferred, second: Deferred) -> Parser {
    return Parser.sequence(Parser.defer(first), Parser.defer(second))
}

public func | (first: Parser, second: Parser) -> Parser {
    return Parser.either(first, second)
}

public func | (first: Parser, second: Deferred) -> Parser {
    return Parser.either(first, Parser.defer(second))
}

public func | (first: Deferred, second: Parser) -> Parser {
    return Parser.either(Parser.defer(first), second)
}

public func | (first: Deferred, second: Deferred) -> Parser {
    return Parser.either(Parser.defer(first), Parser.defer(second))
}

public protocol ParserDSL {
    var recur: Parser { get }
    func recur(_ minimum: Int) -> Parser
    func recur(_ minimum: Int, _ maximum: Int?) -> Parser
    var some: Parser { get }
    var maybe: Parser { get }
    func tag(_ tag: String) -> Parser
}

extension Parser: ParserDSL {

    public var recur: Parser {
        return recur(0, nil)
    }

    public func recur(_ minimum: Int) -> Parser {
        return recur(minimum, nil)
    }

    public func recur(_ minimum: Int, _ maximum: Int?) -> Parser {
        return Parser.repeat(self, minimum: minimum, maximum: maximum)
    }

    public var some: Parser {
        return recur(1)
    }

    public var maybe: Parser {
        return Parser.maybe(self)
    }

    public func tag(_ tag: String) -> Parser {
        return Parser.tagged(tag, self)
    }

}

extension Deferred: ParserDSL {

    fileprivate func wrap() -> Parser {
        return Parser.defer(self)
    }

    public var recur: Parser {
        return wrap().recur
    }

    public func recur(_ minimum: Int) -> Parser {
        return wrap().recur(minimum)
    }

    public func recur(_ minimum: Int, _ maximum: Int?) -> Parser {
        return wrap().recur(minimum, maximum)
    }

    public var some: Parser {
        get {
            return wrap().some
        }
    }

    public var maybe: Parser {
        get {
            return wrap().maybe
        }
    }

    public func tag(_ tag: String) -> Parser {
        return wrap().tag(tag)
    }

}

public extension CountableClosedRange {
    var match: Parser {
        get {
            return makeEither(map(String.init(describing:)))
        }
    }
}

public extension Array {
    var match: Parser {
        get {
            return makeEither(map(String.init(describing:)))
        }
    }
}

public extension String {
    var match: Parser {
        get {
            return makeEither(map(String.init(describing:)))
        }
    }
}

public func makeEither(_ input: [String]) -> Parser {
    return input.tail.reduce(Parser.str(input.head!)) { Parser.either($0, Parser.str($1)) }
}

public let any = Parser.any

public func str(_ str: String) -> Parser {
    return Parser.str(str)
}
