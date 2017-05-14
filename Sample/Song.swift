import Syft

struct SongExpression {
    func evaluate() -> String {
        return "ok"
    }
}

func song() -> Pipeline<SongExpression> {
    return Pipeline(defaultInput: "[].length() = 0\n[_|y].length() = 1.+(y.length())", parser: makeSongParser(), transformer: makeSongTransformer()) { ast in
        let result = ast.evaluate()
        return "\(result)"
    }
}

func makeSongParser() -> ParserProtocol {
    let space = " \t".match
    let skip = space.some.maybe
    let newline = str("\n")
    let skipNewlines = newline.some.maybe
    let dot = str(".")
    let comma = str(",")
    let leftBracket = str("(")
    let rightBracket = str(")")
    let digit = (0...9).match
    let numeral = digit.some
    let letter = "abcdefghijklmnopqrstuvwxyz".match
    let underscore = str("_")
    let identifier = (letter | underscore).some.tag("identifier")
    let functionName = identifier
    let expression = Deferred()
    let argument = skip >>> expression >>> skip
    let arguments = (argument >>> (comma >>> argument).some.maybe).maybe
    let argumentList = leftBracket >>> arguments >>> rightBracket
    let literalList = str("[") >>> arguments.maybe >>> str("]")
    let somethingListPattern = str("[") >>> identifier.tag("head") >>> str("|") >>> identifier.tag("tail") >>> str("]")
    let listPattern = literalList | somethingListPattern
    let subject = listPattern
    let functionCall = subject >>> dot >>> functionName >>> argumentList >>> skip
    expression.parser = numeral | functionCall
    let functionBody = expression
    let assignment = str("=")
    let pattern = listPattern | numeral
    let parameter = skip >>> pattern.tag("parameter") >>> skip
    let parameters = (parameter >>> (comma >>> parameter).some.maybe).maybe
    let parameterList = leftBracket >>> parameters.tag("parameters") >>> rightBracket
    let statement = subject.tag("subject") >>> dot >>> functionName.tag("function") >>> parameterList >>> skip >>> assignment >>> skip >>> functionBody.tag("body") >>> skipNewlines
    let statements = statement.some
    return statements
}

func makeSongTransformer() -> Transformer<SongExpression> {
    let transformer = Transformer<SongExpression>()
    return transformer
}
