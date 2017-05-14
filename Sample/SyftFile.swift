import Syft

func syftFile() -> Pipeline<ArithmeticExpression> {
    return Pipeline(defaultInput: "comma = str(\",\")", parser: makeSyftFileParser(), transformer: makeSyftFileTransformer()) { ast in
        let result = ast.evaluate()
        return "\(result)"
    }
}

func makeSyftFileParser() -> ParserProtocol {
    
    let parser = str(",")
    return parser
}

func makeSyftFileTransformer() -> Transformer<ArithmeticExpression> {
    
    let transformer = Transformer<ArithmeticExpression>()
    return transformer
}
