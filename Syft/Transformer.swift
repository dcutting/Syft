import Foundation

public enum Pattern {
    case simple(String)
    case tree([String: Pattern])
}

typealias Context<T> = [String: T]

public struct Rule<T> {
    let pattern: Pattern
    let action: (Context<T>) throws -> T
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
            return try rule.action(context)
        case let (.tree(patterns), .tagged(tags)):
            var context = [String: T]()
            for (key, subpattern) in patterns {
                let value = tags[key]!
                context[key] = try transform(value)
            }
            return try rule.action(context)
        default:
            return nil
        }
    }
}
