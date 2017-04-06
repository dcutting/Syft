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

public struct Transformation<T> {
    let from: Pattern
    let to: (Result) -> T
    
    init(from: Pattern, to: @escaping (Result) -> T) {
        self.from = from
        self.to = to
    }
}

public enum TransformerError: Error {
    case failure
}

public class Transformer<T> {
    
    var transformations = [Transformation<T>]()
    
    public init() {}
    
    public func append(_ transformation: Transformation<T>) {
        transformations.append(transformation)
    }
    
    public func transform(_ node: Result) throws -> T {
        for rule in transformations {
            if rule.from.matches(node) {
                return rule.to(node)
            }
        }
        throw TransformerError.failure
    }
}
