import Syft

enum SongExpressionError: Error {
    case unknown
}

protocol SongExpression {
    func evaluate() -> String
}

struct SongNumber: SongExpression {
    let value: Int

    func evaluate() -> String {
        return "\(value)"
    }
}

//func song() -> Pipeline<SongExpression> {
////    let input = "[].length() = 0\n[_|y].length() = 1.+(y.length())"
//    let input = ""
//    return Pipeline(defaultInput: input, parser: makeParser(), transformer: makeTransformer()) { ast in
//        let result = ast.evaluate()
//        return "\(result)"
//    }
//}

