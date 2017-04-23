import Foundation


// Errors

public enum TransformerError<T>: Error {
    case inputNotTransformable(Result)
    case transformFailed(Transformable<T>)
    case reducerFailed(Transformable<T>, TransformerPattern, Captures<T>)
    case error
}



// Transformable data structure

public enum Leaf<T> {
    case transformed(T)
    case raw(String)
}

public indirect enum Transformable<T> {
    case tree([String: Transformable<T>])
    // TODO case series
    case leaf(Leaf<T>)
}



// Transformer patterns

public typealias CaptureName = String

public typealias Captures<T> = [CaptureName: Transformable<T>]

public indirect enum TransformerPattern {
    case tree([String: TransformerPattern])
    // TODO case series
    // TODO case literal
    case capture(CaptureName)
    
    func findCaptures<T>(for transformable: Transformable<T>) -> Captures<T>? {
        switch (self, transformable) {
        case let (.capture(name), _):
            return [name: transformable]
        case (.tree, .leaf):
            return nil
        case let (.tree(patternTree), .tree(transformableTree)):
            guard Array(patternTree.keys) == Array(transformableTree.keys) else { return nil }
            var captures: Captures<T> = [:]
            for (key, subPattern) in patternTree {
                let subTransformable = transformableTree[key]!
                let subCaptures = subPattern.findCaptures(for: subTransformable)
                // TODO: same capture name should constrain future matches
                if let subCaptures = subCaptures {
                    captures = captures + subCaptures
                }
            }
            return captures
        }
    }
}



// Tranformer rules

public enum ReducerResult<T> {
    case success(T)
    case noMatch
    case unexpected
}

public typealias Reducer<T> = (Captures<T>) -> ReducerResult<T>

public struct Rule<T> {
    let pattern: TransformerPattern
    let reducer: Reducer<T>
    
    public init(pattern: TransformerPattern, reducer: @escaping Reducer<T>) {
        self.pattern = pattern
        self.reducer = reducer
    }
    
    func apply(to transformable: Transformable<T>) throws -> Transformable<T>? {
        guard let captures = pattern.findCaptures(for: transformable) else { return nil }
        switch reducer(captures) {
        case let .success(reduced):
            return .leaf(.transformed(reduced))
        case .noMatch:
            return nil
        case .unexpected:
            throw TransformerError.reducerFailed(transformable, pattern, captures)
        }
    }
}



// Transformer

public class Transformer<T> {
    
    public init() {}
    
    public func transform(ist: Result, rules: [Rule<T>]) throws -> T {
        let transformable = try makeTransformable(for: ist)
        let result = try transform(transformable: transformable, rules: rules)
        guard case let .leaf(.transformed(value)) = result else { throw TransformerError.transformFailed(result) }
        return value
    }
    
    private func makeTransformable(for ist: Result) throws -> Transformable<T> {
        
        switch ist {
        case .failure:
            throw TransformerError.inputNotTransformable(ist)
        case let .match(value, _):
            return .leaf(.raw(value))
        case let .tagged(tree):
            let transformables = try tree.mapValues { value in
                try makeTransformable(for: value)
            }
            return .tree(transformables)
        case .series:
            // TODO
            throw TransformerError.inputNotTransformable(ist)
        }
    }
    
    private func transform(transformable: Transformable<T>, rules: [Rule<T>]) throws -> Transformable<T> {
        
        switch transformable {
        case let .tree(tree):
            let transformed = try tree.mapValues { value in
                try transform(transformable: value, rules: rules)
            }
            let transformedTree = Transformable.tree(transformed)
            return try apply(rules: rules, to: transformedTree)
        case .leaf(.raw):
            return try apply(rules: rules, to: transformable)
        case .leaf(.transformed):
            return transformable
        }
    }
    
    private func apply(rules: [Rule<T>], to transformable: Transformable<T>) throws -> Transformable<T> {
        for rule in rules {
            if let result = try rule.apply(to: transformable) {
                return result
            }
        }
        return transformable
    }
}
