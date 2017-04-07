import Foundation

public enum Rule<T> {
    case literal(String, (Void) -> T?)
    case simple((String) -> T?)
    case tree([String: String], ([String: T]) -> T?)
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
        switch (rule, result) {
        case let (.literal(literal, action), .match(match, _)):
            guard match == literal else { return nil }
            return action()
        case let (.simple(action), .match(match, _)):
            return action(match)
        case let (.tree(patterns, action), .tagged(tags)):
            var context = [String: T]()
            for (key, name) in patterns {
                let value = tags[key]!
                context[name] = try transform(value)
            }
            return action(context)
        default:
            return nil
        }
    }
}
