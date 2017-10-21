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

struct IotaInc: IotaExpr {
    let body: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        return try body.evaluate(context: context) + 1
    }
}

struct IotaDec: IotaExpr {
    let body: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        return try body.evaluate(context: context) - 1
    }
}

struct IotaEq: IotaExpr {
    let first: IotaExpr
    let second: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        let lhs = try first.evaluate(context: context)
        let rhs = try second.evaluate(context: context)
        return lhs == rhs ? 1 : 0
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

struct IotaIf: IotaExpr {
    let ifeval: IotaExpr
    let texpr: IotaExpr
    let fexpr: IotaExpr

    func evaluate(context: IotaContext) throws -> IotaResult {
        let eval = try ifeval.evaluate(context: context)
        if eval == 0 {  // false
            return try fexpr.evaluate(context: context)
        } else {    // true
            return try texpr.evaluate(context: context)
        }
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
                            return "\(error)"
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
    let def = str("def") >>> skip
    let `if` = str("if") >>> skip
    let inc = str("1+") >>> skip
    let dec = str("1-") >>> skip
    let eq = str("=") >>> skip

    let identifier = skip >>> letter.some.tag("identifier") >>> skip
    let numeral = skip >>> digit.some.tag("numeral") >>> skip
    let literal = numeral
    let variable = identifier.tag("variable")

    let expression = Deferred()

    let body = skip >>> expression >>> skip
    let params = lparen >>> identifier.some.tag("params").maybe >>> rparen
    let function = (lparen >>> def >>> identifier.tag("name") >>> params >>> body.tag("body") >>> rparen).tag("function")

    let arguments = skip >>> (expression >>> skip).some.tag("arguments").maybe >>> skip
    let call = (lparen >>> identifier.tag("name") >>> arguments >>> rparen).tag("call")

    let ifeval = expression.tag("eval")
    let pexpression = skip >>> expression >>> skip
    let tbranch = pexpression
    let fbranch = pexpression
    let ifexpr = (lparen >>> `if` >>> ifeval >>> tbranch.tag("true") >>> fbranch.tag("false") >>> rparen).tag("if")

    let incfunc = (lparen >>> inc >>> expression.tag("body") >>> rparen).tag("inc")
    let decfunc = (lparen >>> dec >>> expression.tag("body") >>> rparen).tag("dec")
    let eqfunc = (lparen >>> eq >>> expression.tag("first") >>> expression.tag("second") >>> rparen).tag("eq")

    expression.parser = literal | variable | ifexpr | incfunc | decfunc | eqfunc | call

    let statement = (function | expression) >>> newline.some.maybe
    let statements = statement.some.tag("statements")
    return statements
}

class IotaTransformer: Transformer<IotaExpr> {

}

func makeIotaTransformer() -> IotaTransformer {

    let transformer = IotaTransformer()

    transformer.rule(["numeral": .simple("num")]) {
        let n = try $0.raw("num")
        guard let value = Int(n) else { throw IotaBuildError.notANumber(n) }
        return IotaNum(value: value)
    }

    transformer.rule([
        "identifier": .simple("id")
    ]) {
        let i = try $0.raw("id")
        return IotaIdentifier(id: i)
    }

    transformer.rule([
        "variable": .simple("var")
    ]) {
        guard let v = try $0.val("var") as? IotaIdentifier else { throw IotaBuildError.notAnIdentifier }
        return IotaVar(id: v)
    }

    transformer.rule(pattern: .tree([
        "call": .tree([
            "arguments": .series("args"),
            "name": .simple("name")
            ])
        ])) {
            guard let n = try $0.val("name") as? IotaIdentifier else { throw IotaBuildError.notAnIdentifier }
            return try IotaCall(funcName: n, arguments: $0.valSeries("args"))
    }

    transformer.rule(pattern: .tree([
        "call": .tree([
            "name": .simple("name")
            ])
        ])) {
            guard let n = try $0.val("name") as? IotaIdentifier else { throw IotaBuildError.notAnIdentifier }
            return IotaCall(funcName: n, arguments: [])
    }

    transformer.rule([
        "function": .tree([
            "body": .simple("body"),
            "name": .simple("name"),
            "params": .series("params")
            ])
    ]) {
        guard
            let n = try $0.val("name") as? IotaIdentifier,
            let p = try $0.valSeries("params") as? [IotaIdentifier]
            else { throw IotaBuildError.notAnIdentifier }
        return try IotaFunc(name: n, params: p, body: $0.val("body"))
    }

    transformer.rule([
        "function": .tree([
            "body": .simple("body"),
            "name": .simple("name")
            ])
    ]) {
        guard
            let n = try $0.val("name") as? IotaIdentifier
            else { throw IotaBuildError.notAnIdentifier }
        return try IotaFunc(name: n, params: [], body: $0.val("body"))
    }

    transformer.rule([
        "inc": .tree([
            "body": .simple("body")
            ])
    ]) {
        return try IotaInc(body: $0.val("body"))
    }

    transformer.rule([
        "dec": .tree([
            "body": .simple("body")
            ])
    ]) {
        return try IotaDec(body: $0.val("body"))
    }

    transformer.rule([
        "eq": .tree([
            "first": .simple("first"),
            "second": .simple("second")
            ])
    ]) {
        return try IotaEq(first: $0.val("first"), second: $0.val("second"))
    }

    transformer.rule([
        "if": .tree([
            "eval": .simple("eval"),
            "true": .simple("true"),
            "false": .simple("false")
            ])
    ]) {
        let ifeval = try $0.val("eval")
        let texpr = try $0.val("true")
        let fexpr = try $0.val("false")
        return IotaIf(ifeval: ifeval, texpr: texpr, fexpr: fexpr)
    }

    transformer.rule(pattern: .tree(["statements": .series("statements")])) {
        let p = try $0.valSeries("statements")
        return IotaProgram(statements: p)
    }

    return transformer
}
