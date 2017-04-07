import Foundation

public enum Pattern {
    case simple(String)
//    case tree([String: Pattern])
}

typealias Context = [String: String]

public struct Rule<T> {
    let pattern: Pattern
    let action: (Context) -> T?
}

public enum TransformerError: Error {
    case failure
}

public class Transformer<T> {
    
    var rules = [Rule<T>]()
    
    public init() {}
    
    public func append(_ rule: Rule<T>) {
        rules.append(rule)
    }
    
    public func transform(_ result: Result) throws -> T {
        for rule in rules {
            if let transformed = try apply(rule, to: result) {
                return transformed
            }
        }
        throw TransformerError.failure
    }

    func apply(_ rule: Rule<T>, to result: Result) throws -> T? {
        switch (rule.pattern, result) {
        case let (.simple(name), .match(match, _)):
            let context = [name: match]
            return rule.action(context)
//        case let (.tree(patterns, action), .tagged(tags)):
//            var context = [String: T]()
//            for (key, name) in patterns {
//                let value = tags[key]!
//                context[name] = try transform(value)
//            }
//            return action(context)
        default:
            return nil
        }
    }
}
