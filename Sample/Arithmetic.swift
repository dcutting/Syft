import Syft

protocol ArithmeticExpression {
    func evaluate() -> Int
}

struct ArithmeticConstant: ArithmeticExpression {
    let value: Int
    
    func evaluate() -> Int {
        return value
    }
}

struct ArithmeticOperation: ArithmeticExpression {
    let first: ArithmeticExpression
    let second: ArithmeticExpression
    let function: (Int, Int) -> Int
    
    func evaluate() -> Int {
        return function(first.evaluate(), second.evaluate())
    }
}

func runArithmetic() {
    do {
        let polishNotationInput = "+ 3 - * 8 5 9"
        print("\(polishNotationInput)\n")
        let intermediateSyntaxTree = makeArithmeticParser().parse(polishNotationInput)
        print("\(intermediateSyntaxTree)\n")
        let abstractSyntaxTree = try makeArithmeticTransformer().transform(intermediateSyntaxTree)
        print("\(abstractSyntaxTree)\n")
        let result = abstractSyntaxTree.evaluate()
        print("\(polishNotationInput) = \(result)")
    } catch {
        print(error)
    }
}

func makeArithmeticParser() -> ParserProtocol {

    let space = " ".match
    let skip = space.some.maybe
    let digit = (0...9).match
    let op = "+-*".match.tag("op") >>> skip
    let numeral = skip >>> digit.some.tag("numeral") >>> skip
    let expression = Deferred()
    let compound = op >>> expression.tag("first") >>> expression.tag("second")
    expression.parser = compound | numeral
    return expression
}

enum ArithmeticError: Error {
    case notAConstant
}

func makeArithmeticTransformer() -> Transformer<ArithmeticExpression> {

    let transformer = Transformer<ArithmeticExpression>()

    transformer.transform(["numeral": .simple("x")]) { args in
        guard let int = Int(try args.raw("x")) else { throw ArithmeticError.notAConstant }
        return ArithmeticConstant(value: int)
    }
    
    transformer.transform(["first": .simple("f"), "second": .simple("s"), "op": .literal("+")]) { args in
        ArithmeticOperation(first: try args.transformed("f"), second: try args.transformed("s")) { a, b in a + b }
    }
    
    transformer.transform(["first": .simple("f"), "second": .simple("s"), "op": .literal("-")]) { args in
        ArithmeticOperation(first: try args.transformed("f"), second: try args.transformed("s")) { a, b in a - b }
    }
    
    transformer.transform(["first": .simple("f"), "second": .simple("s"), "op": .literal("*")]) { args in
        ArithmeticOperation(first: try args.transformed("f"), second: try args.transformed("s")) { a, b in a * b }
    }
    
    return transformer
}
