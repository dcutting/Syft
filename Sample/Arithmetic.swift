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

func makeArithmeticTransformer() -> Transformer<ArithmeticExpression> {

    let constantReducer: TransformerReducer<ArithmeticExpression> = { captures in
        guard let x = captures["x"] else { return .unexpected }
        switch x {
        case let .leaf(.raw(value)):
            guard let int = Int(value) else { return .unexpected }
            let constant = ArithmeticConstant(value: int)
            return .success(constant)
        default:
            return .unexpected
        }
    }
    let constantRule = TransformerRule(
        pattern: .tree(["numeral": .capture("x")]),
        reducer: constantReducer
    )
    
    let plusReducer: TransformerReducer<ArithmeticExpression> = { captures in
        guard let x = captures["x"] else { return .unexpected }
        guard let y = captures["y"] else { return .unexpected }
        guard let op = captures["op"] else { return .unexpected }
        guard case .leaf(.raw("+")) = op else { return .noMatch }
        switch (x, y) {
        case let (.leaf(.transformed(left)), .leaf(.transformed(right))):
            let plus = ArithmeticPlus(first: left, second: right)
            return .success(plus)
        default:
            return .unexpected
        }
    }
    let plusRule = TransformerRule(
        pattern: .tree(["first": .capture("x"), "second": .capture("y"), "op": .capture("op")]),
        reducer: plusReducer
    )
    
    return Transformer(rules: [constantRule, plusRule])
}
