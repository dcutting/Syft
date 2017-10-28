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

    // Punctuation.

    let space = " \t".match.some
    let skip = space.maybe
    let dot = str(".")
    let pipe = str("|") >>> skip
    let comma = str(",") >>> skip
    let lBracket = str("[") >>> skip
    let rBracket = str("]") >>> skip
    let lParen = str("(") >>> skip
    let rParen = str(")")
    let quote = str("'")
    let digit = (0...9).match
    let letter = "abcdefghijklmnopqrstuvwxyz".match
    let times = str("*")
    let dividedBy = str("/")
    let modulo = str("%")
    let plus = str("+")
    let minus = str("-")
    let lessThanOrEqual = str("<=")
    let greaterThanOrEqual = str(">=")
    let lessThan = str("<")
    let greaterThan = str(">")

    let expression = Deferred()
    let term = Deferred()
    let pattern = Deferred()
    let atom = Deferred()

    // Atoms.

    // RESERVED_WORDS = %w( yes no not and or if use class eq neq Boolean List String Number )
    let name = (letter >>> (letter | digit).some.maybe).tag("identifier")
    let stringValue = quote >>> letter.recur >>> quote >>> skip
    let float = (minus.maybe >>> digit.some >>> dot >>> digit.some).tag("float")
    let integer = (minus.maybe >>> digit.some).tag("int")
    let number = float | integer
    let trueValue = str("YES").tag("true")
    let falseValue = str("NO").tag("false")

    // Patterns.

    let listPattern = lBracket >>> (pattern.tag("headItem") >>> (comma >>> pattern.tag("headItem")).recur).tag("headItems") >>> (pipe >>> name.tag("tail")).maybe >>> rBracket
    let listParamPattern = lBracket >>> (pattern.tag("listItem") >>> (comma >>> pattern.tag("listItem")).recur).maybe.tag("list") >>> rBracket
    pattern.parser = listParamPattern | listPattern | number | trueValue | falseValue | stringValue | name

    // Expressions.

    let multiplicativeExpression = term.tag("left") >>> (skip >>> (times | dividedBy | modulo).tag("op") >>> skip >>> term.tag("right")).recur.tag("ops")

    let additiveExpression = multiplicativeExpression.tag("left") >>> (skip >>> (plus | minus).tag("op") >>> skip >>> multiplicativeExpression.tag("right")).recur.tag("ops")

    let relationalExpression = Deferred()
    relationalExpression.parser = additiveExpression.tag("left") >>> (skip >>> (lessThanOrEqual | greaterThanOrEqual | lessThan | greaterThan).tag("op") >>> skip >>> relationalExpression.tag("right")).recur.tag("ops")

    let equals = str("EQ")
    let notEquals = str("NEQ")
    let equalityExpression = Deferred()
    equalityExpression.parser = relationalExpression.tag("left") >>> (space >>> (equals | notEquals).tag("op") >>> space >>> equalityExpression.tag("right")).recur.tag("ops")

    let andKeyword = str("AND")
    let andExpression = Deferred()
    andExpression.parser = equalityExpression.tag("left") >>> (space >>> andKeyword.tag("op") >>> space >>> andExpression.tag("right")).recur.tag("ops")

    let orKeyword = str("OR")
    let orExpression = Deferred()
    orExpression.parser = andExpression.tag("left") >>> (space >>> orKeyword.tag("op") >>> space >>> orExpression.tag("right")).recur.tag("ops")

    expression.parser = orExpression.parser

    // Function chains.

    let functionArguments = expression.tag("arg") >>> (comma >>> expression.tag("arg")).recur
    let functionCall = dot >>> name.tag("funcName") >>> (lParen >>> functionArguments.tag("args").maybe >>> rParen).maybe
    let functionChain = atom.tag("subject") >>> functionCall.some.tag("calls")

    // Functions.

    let parameter = pattern
    let functionSubject = parameter.tag("defunSubject")
    let functionName = name.tag("FUNC")
    let parameters = parameter.tag("param") >>> (comma >>> parameter.tag("param")).recur
    let functionParameters = lParen >>> parameters.recur(0, 1).tag("params") >>> rParen
    let assign = skip >>> str("=") >>> skip
    let functionBody = expression.tag("body") >>> skip
    let ifKeyword = space >>> str("IF") >>> space
    let guardClause = (ifKeyword >>> expression).maybe.tag("guard")
    let function = functionSubject >>> dot >>> functionName >>> functionParameters.maybe >>> guardClause >>> assign >>> functionBody

    // Lambdas.

    let lambdaParameters = pipe >>> parameters.tag("params") >>> pipe
    let lambdaBody = expression.tag("lambdaBody") >>> skip
    let lambda = (lambdaParameters >>> lambdaBody).tag("lambda")

    // Terms.

    let notKeyword = str("NOT").tag("not") >>> space
    let negatedTerm = notKeyword >>> term.tag("negatedTerm")
    term.parser = negatedTerm | functionChain | lambda | atom

    let list = (lBracket >>> (expression.tag("listItem") >>> (comma >>> expression.tag("listItem")).recur).maybe.tag("list") >>> rBracket)
    let wrappedExpression = lParen >>> expression.tag("expression") >>> rParen
    atom.parser = wrappedExpression | list | listPattern | number | name | trueValue | falseValue | stringValue

    // Imports.

    let importKeyword = str("Use") >>> space
    let importFilename = stringValue
    let `import` = importKeyword >>> importFilename.tag("import")

    // Classes.

    let numberKeyword = str("Number") >>> skip
    let booleanKeyword = str("Boolean") >>> skip
    let stringKeyword = str("String") >>> skip
    let listKeyword = str("List") >>> skip
    let className = numberKeyword | booleanKeyword | stringKeyword | listKeyword
    let classKeyword = str("Class") >>> space
    let classDeclaration = classKeyword >>> className.tag("subjectType")

    // Root.

    let statement = classDeclaration >>> `import` >>> function >>> expression
    let program = skip >>> statement

    return expression
}

//    let listPattern = (list | listTemplate).tag("listPattern")
//    let listTemplate = (lBracket >>> pattern.tag("head") >>> pipe >>> identifier.tag("tail") >>> rBracket).tag("listTemplate")
//    let newline = str("\n")
//    let skipNewlines = newline.some.maybe
//    let dot = str(".")
//    let minus = str("-")
//    let underscore = str("_")
//    let assignment = str("=")
//
//    let variable = identifier.tag("variable")
//
//    let literal = list | numeral
//
//    let object = (literal | variable).tag("object")
//    let name = identifier.tag("name")
//    let arguments = (lParen >>> listBare >>> rParen).tag("arguments")
//    let call = (object >>> dot >>> name >>> arguments).tag("call")
//
//    evaluable.parser = literal | variable | call
//
//    let parameter = skip >>> pattern.tag("parameter") >>> skip
//    let parameters = (parameter.recur(1, 1) >>> (comma >>> parameter).some.maybe).tag("parameters")
//    let parameterList = (lParen >>> parameters >>> rParen).maybe.tag("parameterList")
//    let functionBody = evaluable
//
//    let subject = listPattern | literal | variable
//    let rule = subject.tag("subject") >>> dot >>> name.tag("function") >>> parameterList >>> skip >>> assignment >>> skip >>> functionBody.tag("body")
//
//    let rules = rule.recur
//
//    expression.parser = evaluable | rule
//
//    return call
//}

func makeSongTransformer() -> Transformer<SongExpression> {
    let transformer = Transformer<SongExpression>()

    transformer.rule(["subject": .simple("s")]) {
        guard let value = try Int($0.str("s")) else { throw SongExpressionError.unknown }
        return SongNumber(value: value)
    }

    return transformer
}
