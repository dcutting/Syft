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

protocol IotaExpr {
    func evaluate(context: IotaContext) throws -> IotaResult
}

struct IotaIdentifier: IotaExpr {
    let id: String

    func evaluate(context: IotaContext) throws -> IotaResult {
        throw IotaRuntimeError.cannotEvaluate(id)
    }
}

struct IotaNum: IotaExpr {
    let value: Int

    func evaluate(context: IotaContext) throws -> IotaResult {
        return value
    }
}

struct IotaVar: IotaExpr {
    let id: IotaIdentifier

    func evaluate(context: IotaContext) throws -> IotaResult {
        guard let value = context[id.id] else { throw IotaRuntimeError.noSuchVariable(id.id) }
        return try value.evaluate(context: context)
    }
}

struct IotaFunc: IotaExpr {
    let name: IotaIdentifier
    let params: [IotaIdentifier]
    let body: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        return try body.evaluate(context: context)
    }
}

struct IotaCall: IotaExpr {
    let funcName: IotaIdentifier
    let arguments: [IotaExpr]

    func evaluate(context: IotaContext) throws -> IotaResult {
        guard let value = context[funcName.id] else { throw IotaRuntimeError.noSuchVariable(funcName.id) }
        guard let function = value as? IotaFunc else { throw IotaRuntimeError.notAFunction(funcName.id) }
        let evaluatedArgs = try arguments.map {
            try $0.evaluate(context: context)
        }.map(IotaNum.init)
        let callContext = zip(function.params, evaluatedArgs).reduce(context) { context, paramArg in
            let (p, a) = paramArg
            return context.append(param: p.id, arg: a)
        }
        return try function.evaluate(context: callContext)
    }
}

struct IotaProgram: IotaExpr {
    let statements: [IotaExpr]

    init(statements: [IotaExpr]) {
        self.statements = statements
    }

    private var functions = [String: IotaFunc]()

    func evaluate(context: IotaContext) throws -> IotaResult {
        throw IotaRuntimeError.cannotEvaluate("")
    }

    func run() throws -> String {
        var output = ""
        var context = IotaContext()
        try statements.forEach { statement in
            if let function = statement as? IotaFunc {
                context = context.append(param: function.name.id, arg: function)
            } else {
                let result = try statement.evaluate(context: context)
                output += "\(result)"
            }
        }
        return output
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
                            guard let program = ast as? IotaProgram else { throw IotaRuntimeError.cannotEvaluate("") }
                            let result = try program.run()
                            return "\(result)"
                        } catch {
                            return "error"
                        }
    }
}

func makeIotaParser() -> ParserProtocol {

    /*
     (def head (a b) a)
     (head 9 5)
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
    let params = lparen >>> identifier.some.maybe >>> rparen
    let function = (lparen >>> def >>> identifier.tag("name") >>> params.tag("params") >>> body.tag("body") >>> rparen).tag("function")

    let arguments = skip >>> expression.some.maybe >>> skip
    let call = (lparen >>> identifier.tag("name") >>> arguments.tag("arguments") >>> rparen).tag("call")

    expression.parser = literal | variable | call

    let statement = function | expression
    let statements = (statement >>> (newline.some >>> statement).some.maybe).tag("statements")
    return statements
}

class IotaTransformer: Transformer<IotaExpr> {

}

func makeIotaTransformer() -> IotaTransformer {

    let transformer = IotaTransformer()

    transformer.rule(["numeral": .simple("n")]) {
        let n = try $0.raw("n")
        guard let value = Int(n) else { throw IotaBuildError.notANumber(n) }
        return IotaNum(value: value)
    }

    transformer.rule([
        "identifier": .simple("i")
    ]) {
        let i = try $0.raw("i")
        return IotaIdentifier(id: i)
    }

    transformer.rule([
        "variable": .simple("v")
    ]) {
        guard let v = try $0.val("v") as? IotaIdentifier else { throw IotaBuildError.notAnIdentifier }
        return IotaVar(id: v)
    }

    transformer.rule(pattern: .tree([
        "call": .tree([
            "arguments": .series("a"),
            "name": .simple("n")
        ])
    ])) {
        guard let n = try $0.val("n") as? IotaIdentifier else { throw IotaBuildError.notAnIdentifier }
        return try IotaCall(funcName: n, arguments: $0.valSeries("a"))
    }

    transformer.rule([
        "function": .tree([
            "body": .simple("b"),
            "name": .simple("n"),
            "params": .series("p")
        ])
    ]) {
        guard
            let n = try $0.val("n") as? IotaIdentifier,
            let p = try $0.valSeries("p") as? [IotaIdentifier]
            else { throw IotaBuildError.notAnIdentifier }
        return try IotaFunc(name: n, params: p, body: $0.val("b"))
    }

    transformer.rule(pattern: .tree(["statements": .series("p")])) {
        let p = try $0.valSeries("p")
        return IotaProgram(statements: p)
    }

    return transformer
}
