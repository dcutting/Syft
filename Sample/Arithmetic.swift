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

struct ArithmeticPlus: ArithmeticExpression {
    let first: ArithmeticExpression
    let second: ArithmeticExpression
    
    func evaluate() -> Int {
        return first.evaluate() + second.evaluate()
    }
}

func runArithmetic() {
    do {
        let input = "  123+  52 \t  \n +  891 \r\n  +3120   "
        let intermediateSyntaxTree = makeArithmeticParser().parse(input)
        let abstractSyntaxTree = try makeArithmeticTransformer().transform(intermediateSyntaxTree)
        let result = abstractSyntaxTree.evaluate()
        print("\(input) = \(result)")
    } catch {
        print(error)
    }
}

func makeArithmeticParser() -> ParserProtocol {

    let space = " \t\n\r\n".match
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

    let constantRule = TransformerRule<ArithmeticExpression>(
        pattern: .tree(["numeral": .capture("x")]),
        reducer: { args in
            guard let int = Int(try args.raw("x")) else { throw ArithmetricError.notAConstant }
            return ArithmeticConstant(value: int)
        }
    )
    
    let plusRule = TransformerRule<ArithmeticExpression>(
        pattern: TransformerPattern.tree(["first": .capture("first"), "second": .capture("second"), "op": .capture("op")]),
        reducer: { args in
            guard try args.raw("op") == "+" else { return nil }
            return ArithmeticPlus(first: try args.transformed("first"), second: try args.transformed("second"))
        }
    )
    
    return Transformer(rules: [constantRule, plusRule])
}
