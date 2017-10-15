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

enum IotaError: Error {
    case noSuchVariable(String)
    case notAFunction(String)
}

protocol IotaExpr {
    func evaluate(context: IotaContext) throws -> IotaResult
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
        guard let value = context[id] else { throw IotaError.noSuchVariable(id) }
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
        guard let value = context[funcName] else { throw IotaError.noSuchVariable(funcName) }
        guard let function = value as? IotaFunc else { throw IotaError.notAFunction(funcName) }
        let argResult = try argument.evaluate(context: context)
        let arg = IotaNum(value: argResult)
        let callContext = context.append(param: function.param, arg: arg)
        return try function.evaluate(context: callContext)
    }
}

