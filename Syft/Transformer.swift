import Foundation

public enum Rule<T> {
    case literal(String, (String) -> T?)
    
    func apply(_ result: Result) -> T? {
        switch (self, result) {
        case let (.literal(literal, action), .match(match, _)):
            guard match == literal else { return nil }
            return action(match)
        default:
            return nil
        }
    }
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
            if let transformed = rule.apply(result) {
                return transformed
            }
        }
        throw TransformerError.failure
    }
}
