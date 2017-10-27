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

func song() -> Pipeline<SongExpression> {
//    let input = "[].length() = 0\n[_|y].length() = 1.+(y.length())"
    let input = ""
    return Pipeline(defaultInput: input, parser: makeSongParser(), transformer: makeSongTransformer()) { ast in
        let result = ast.evaluate()
        return "\(result)"
    }
}

func makeSongParser() -> ParserProtocol {
    let space = " \t".match.some
    let skip = space.maybe
    let pipe = str("|") >>> skip
    let comma = str(",") >>> skip
    let lBracket = str("[") >>> skip
    let rBracket = str("]") >>> skip
    let lParen = str("(") >>> skip
    let rParen = str(")")

    let expression = Deferred()
    let evaluable = Deferred()
    let pattern = Deferred()

    let listElement = skip >>> evaluable.tag("listElement") >>> skip
    let listBare = (listElement >>> (comma >>> listElement).some.maybe).maybe.tag("listBare")
    let listLiteral = (lBracket >>> listBare >>> rBracket).tag("listLiteral")

    let newline = str("\n")
    let skipNewlines = newline.some.maybe
    let dot = str(".")
    let minus = str("-")
    let underscore = str("_")
    let assignment = str("=")
    let digit = (0...9).match
    let letter = "abcdefghijklmnopqrstuvwxyz".match

    let numeral = (minus.maybe >>> digit.some).tag("numeral")
    let identifier = (letter >>> (letter | digit).some.maybe).tag("identifier")
    let variable = identifier.tag("variable")

    let listTemplate = (lBracket >>> pattern.tag("head") >>> pipe >>> identifier.tag("tail") >>> rBracket).tag("listTemplate")
    let listPattern = (listLiteral | listTemplate).tag("listPattern")

    let literal = listLiteral | numeral

    let object = (literal | variable).tag("object")
    let name = identifier.tag("name")
    let arguments = (lParen >>> listBare >>> rParen).tag("arguments")
    let call = (object >>> dot >>> name >>> arguments).tag("call")

    evaluable.parser = literal | variable | call

    pattern.parser  = listPattern | listLiteral | numeral | identifier
    let parameter = skip >>> pattern.tag("parameter") >>> skip
    let parameters = (parameter.recur(1, 1) >>> (comma >>> parameter).some.maybe).tag("parameters")
    let parameterList = (lParen >>> parameters >>> rParen).maybe.tag("parameterList")
    let functionBody = evaluable

    let subject = listPattern | literal | variable
    let rule = subject.tag("subject") >>> dot >>> name.tag("function") >>> parameterList >>> skip >>> assignment >>> skip >>> functionBody.tag("body")

    let rules = rule.recur

    expression.parser = evaluable | rule

    return call
}

func makeSongTransformer() -> Transformer<SongExpression> {
    let transformer = Transformer<SongExpression>()

    transformer.rule(["subject": .simple("s")]) {
        guard let value = try Int($0.str("s")) else { throw SongExpressionError.unknown }
        return SongNumber(value: value)
    }

    return transformer
}
