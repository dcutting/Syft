import Syft

typealias IotaResult = Int

struct IotaContext {
    var values = [String: IotaExpr]()

    subscript(id: String) -> IotaExpr? {
        return values[id]
    }

    func append(param: String, arg: IotaExpr) -> IotaContext {
        var dup = self
        dup.values[param] = arg
        return dup
    }
}

enum IotaBuildError: Error {
    case notANumber(String)
    case notAnIdentifier
}

enum IotaRuntimeError: Error {
    case noSuchVariable(String)
    case notAFunction(String)
    case cannotEvaluate(String)
}

protocol IotaExpr {}

extension IotaExpr {
    func evaluate(context: IotaContext) throws -> IotaResult {
        throw IotaRuntimeError.cannotEvaluate("unknown")
    }
}

struct IotaNum: IotaExpr {
    let value: Int

    func evaluate(context: IotaContext) throws -> IotaResult {
        return value
    }
}

struct IotaVar: IotaExpr {
    let id: String

    func evaluate(context: IotaContext) throws -> IotaResult {
        guard let value = context[id] else { throw IotaRuntimeError.noSuchVariable(id) }
        return try value.evaluate(context: context)
    }
}

struct IotaFunc: IotaExpr {
    let param: String
    let body: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        return try body.evaluate(context: context)
    }
}

struct IotaCall: IotaExpr {
    let funcName: String
    let argument: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        guard let value = context[funcName] else { throw IotaRuntimeError.noSuchVariable(funcName) }
        guard let function = value as? IotaFunc else { throw IotaRuntimeError.notAFunction(funcName) }
        let argResult = try argument.evaluate(context: context)
        let arg = IotaNum(value: argResult)
        let callContext = context.append(param: function.param, arg: arg)
        return try function.evaluate(context: callContext)
    }
}

func iota() -> Pipeline<IotaExpr> {
    return Pipeline(defaultInput: """
(def identity (a) a)
(identity 5)
""",
                    parser: makeIotaParser(),
                    transformer: makeIotaTransformer()) { ast in
                        do {
                            let result = try ast.evaluate(context: IotaContext())
                            return "\(result)"
                        } catch {
                            return "error"
                        }
    }
}

func makeIotaParser() -> ParserProtocol {

    /*
     (def identity (a) a)
     (identity 5)
     */

    let space = " \t\n".match
    let spaces = space.some
    let skip = spaces.maybe
    let newline = str("\n")
    let lparen = str("(")
    let rparen = str(")")
    let digit = (0...9).match
    let letter = "abcdefghijklmnopqrstuvwxyz".match
    let def = str("def")

    let identifier = skip >>> letter.some.tag("identifier") >>> skip
    let numeral = skip >>> digit.some.tag("numeral") >>> skip
    let literal = numeral
    let variable = identifier.tag("variable")

    let expression = Deferred()

    let body = skip >>> expression >>> skip
    let params = lparen >>> identifier >>> rparen
    let function = (lparen >>> def >>> identifier.tag("name") >>> params.tag("params") >>> body.tag("body") >>> rparen).tag("function")

    let argument = skip >>> expression >>> skip
    let call = (lparen >>> identifier.tag("name") >>> argument.tag("argument") >>> rparen).tag("call")

    expression.parser = literal | variable | call

    let statement = function | expression
    let statements = statement >>> (newline.some >>> statement).some.maybe
    return statements
}

func makeIotaTransformer() -> Transformer<IotaExpr> {

    let transformer = Transformer<IotaExpr>()

    transformer.rule(["numeral": .simple("n")]) {
        let n = try $0.raw("n")
        guard let value = Int(n) else { throw IotaBuildError.notANumber(n) }
        return IotaNum(value: value)
    }

    transformer.rule([
        "variable": .tree([
            "identifier": .simple("v")
        ])
    ]) {
        let v = try $0.raw("v")
        return IotaVar(id: v)
    }

    transformer.rule([
        "call": .tree([
            "argument": .simple("a"),
            "name": .tree([
                "identifier": .simple("n")
            ])
        ])
    ]) {
        return try IotaCall(funcName: try $0.raw("n"), argument: $0.val("a"))
    }

    transformer.rule([
        "function": .tree([
            "body": .simple("b"),
            "name": .tree([
                "identifier": .simple("n")
            ]),
            "params": .tree([
                "identifier": .simple("p")
            ])
        ])
    ]) {
        let p = try $0.raw("p")
        return try IotaFunc(param: p, body: $0.val("b"))
    }

    return transformer
}
