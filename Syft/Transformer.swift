import Foundation

public enum Pattern {
    case literal(String)
    
    func matches(_ result: Result) -> Bool {
        switch (self, result) {
        case let (.literal(literal), .match(match, _)):
            return match == literal
        default:
            return false
        }
    }
}

public struct Rule<T> {
    let pattern: Pattern
    let action: (Result) -> T
    
    init(replace pattern: Pattern, with action: @escaping (Result) -> T) {
        self.pattern = pattern
        self.action = action
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
    
    public func transform(_ node: Result) throws -> T {
        for rule in rules {
            if rule.pattern.matches(node) {
                return rule.action(node)
            }
        }
        throw TransformerError.failure
    }
}
