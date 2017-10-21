import Syft

protocol Expr {
    func evaluate() -> Double
}

struct Num: Expr {
    let value: Double
    
    func evaluate() -> Double {
        return value
    }
}

struct Plus: Expr {
    let first: Expr
    let second: Expr

    func evaluate() -> Double {
        return first.evaluate() + second.evaluate()
    }
}

struct Minus: Expr {
    let first: Expr
    let second: Expr

    func evaluate() -> Double {
        return first.evaluate() - second.evaluate()
    }
}

struct Times: Expr {
    let first: Expr
    let second: Expr

    func evaluate() -> Double {
        return first.evaluate() * second.evaluate()
    }
}

struct Divide: Expr {
    let first: Expr
    let second: Expr

    func evaluate() -> Double {
        return first.evaluate() / second.evaluate()
    }
}

func arithmetic() -> Pipeline<Expr> {
    return Pipeline(defaultInput: "+ 1 2", parser: makeArithmeticParser(), transformer: makeArithmeticTransformer()) { ast in
        let result = ast.evaluate()
        return "\(result)"
    }
}

func makeArithmeticParser() -> ParserProtocol {

    let space = " ".match
    let skip = space.some.maybe
    let digit = (0...9).match
    let op = skip >>> "+-*/".match.tag("op") >>> skip
    let numeral = skip >>> digit.some.tag("n") >>> skip
    let expression = Deferred()
    let compound = op >>> expression.tag("a") >>> expression.tag("b")
    expression.parser = compound | numeral
    return expression
}

enum ExprError: Error {
    case notAConstant
}

func makeArithmeticTransformer() -> Transformer<Expr> {

    let transformer = Transformer<Expr>()

    transformer.rule(["n": .simple("n")]) {
        guard let value = Double(try $0.str("n")) else { throw ExprError.notAConstant }
        return Num(value: value)
    }
    
    transformer.rule(["a": .simple("a"), "b": .simple("b"), "op": .literal("+")]) {
        try Plus(first: $0.val("a"), second: $0.val("b"))
    }
    
    transformer.rule(["a": .simple("a"), "b": .simple("b"), "op": .literal("-")]) {
        try Minus(first: $0.val("a"), second: $0.val("b"))
    }

    transformer.rule(["a": .simple("a"), "b": .simple("b"), "op": .literal("*")]) {
        try Times(first: $0.val("a"), second: $0.val("b"))
    }

    transformer.rule(["a": .simple("a"), "b": .simple("b"), "op": .literal("/")]) {
        try Divide(first: $0.val("a"), second: $0.val("b"))
    }

    return transformer
}
