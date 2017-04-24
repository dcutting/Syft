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
        let input = "  123+  52 \t +  891   -3120   "
        let intermediateSyntaxTree = makeArithmeticParser().parse(input)
        let abstractSyntaxTree = try makeArithmeticTransformer().transform(intermediateSyntaxTree)
        let result = abstractSyntaxTree.evaluate()
        print("\(input) = \(result)")
    } catch {
        print(error)
    }
}

func makeArithmeticParser() -> ParserProtocol {

    let space = " \t".match
    let skip = space.some.maybe
    let digit = (0...9).match
    let op = "+-*/".match.tag("op") >>> skip
    let numeral = skip >>> digit.some.tag("numeral") >>> skip
    let expression = Deferred()
    let compound = numeral.tag("first") >>> op >>> expression.tag("second")
    expression.parser = compound | numeral
    return expression
}

enum ArithmetricError: Error {
    case notAConstant
}

func makeArithmeticTransformer() -> Transformer<ArithmeticExpression> {

    let transformer = Transformer<ArithmeticExpression>()

    transformer.transform(["numeral": .simple("x")]) { args in
        guard let int = Int(try args.raw("x")) else { throw ArithmetricError.notAConstant }
        return ArithmeticConstant(value: int)
    }
    
    transformer.transform(["first": .simple("first"),
                           "second": .simple("second"),
                           "op": .literal("+")]
    ) { args in
        ArithmeticOperation(first: try args.transformed("first"), second: try args.transformed("second"), function: { a, b in a + b })
    }
    
    transformer.transform(["first": .simple("first"),
                           "second": .simple("second"),
                           "op": .literal("-")]
    ) { args in
        ArithmeticOperation(first: try args.transformed("first"), second: try args.transformed("second"), function: { a, b in a - b })
    }
    
    transformer.transform(["first": .simple("first"),
                           "second": .simple("second"),
                           "op": .literal("*")]
    ) { args in
        ArithmeticOperation(first: try args.transformed("first"), second: try args.transformed("second"), function: { a, b in a * b })
    }
    
    transformer.transform(["first": .simple("first"),
                           "second": .simple("second"),
                           "op": .literal("/")]
    ) { args in
        ArithmeticOperation(first: try args.transformed("first"), second: try args.transformed("second"), function: { a, b in a / b })
    }
    
    return transformer
}
