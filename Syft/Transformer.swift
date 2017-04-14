import Foundation

public enum Partial<T> {
    case transformed(T)
    case capture(String)
}

typealias Context<T> = [String: Partial<T>]

public enum Pattern {
    case simple(String)
    case tree([String: Pattern])
    
    func apply<T>(to result: Result) -> Context<T> {
        switch (self, result) {
        case let (.simple(name), .match(match, _)):
            return [name: Partial.capture(match)]
        case let (.tree(patterns), .tagged(tags)):
            var merged: Context<T> = [:]
            for (key, subpattern) in patterns {
                let subtree = tags[key]!
                let context: Context<T> = subpattern.apply(to: subtree)
                merged = mergeContexts(a: merged, b: context)
            }
        }
    }
}

private func mergeContexts<T>(a: Context<T>, b: Context<T>) -> Context<T> {
    var merged: Context<T> = [:]
    for (k, v) in a {
        merged[k] = v
    }
    for (k, v) in b {
        merged[k] = v
    }
    return merged
}

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
