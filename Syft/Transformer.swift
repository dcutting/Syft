import Foundation


// Errors

public enum TransformerError<T>: Error {
    case inputNotTransformable(Result)
    case transformFailed(Transformable<T>)
    case reducerFailed(Transformable<T>, TransformerPattern, TransformerCaptures<T>)
    case unknownCaptureVariable(TransformerCaptureName)
    case captureVariableUnexpectedlyRaw(TransformerCaptureName)
    case captureVariableUnexpectedlyTransformed(TransformerCaptureName)
}



// Transformable data structure

public enum TransformableLeaf<T> {
    case transformed(T)
    case raw(String)
}

public typealias TransformableTree<T> = [String: Transformable<T>]

public indirect enum Transformable<T> {
    case tree(TransformableTree<T>)
    // TODO case series
    case leaf(TransformableLeaf<T>)
}



// Transformer patterns

public typealias TransformerCaptureName = String

public typealias TransformerCaptures<T> = [TransformerCaptureName: Transformable<T>]

public struct TransformerReducerArguments<T> {
    var captures: TransformerCaptures<T> = [:]
    
    public func transformed(_ key: String) throws -> T {
        let value = try get(key: key)
        guard case let .leaf(.transformed(transformed)) = value else {
            throw TransformerError<T>.captureVariableUnexpectedlyRaw(key)
        }
        return transformed
    }
    
    public func raw(_ key: String) throws -> String {
        let value = try get(key: key)
        guard case let .leaf(.raw(raw)) = value else {
            throw TransformerError<T>.captureVariableUnexpectedlyTransformed(key)
        }
        return raw
    }
    
    private func get(key: String) throws -> Transformable<T> {
        guard let value = captures[key] else { throw TransformerError<T>.unknownCaptureVariable(key) }
        return value
    }
}

public typealias TransformerPatternTree = [String: TransformerPattern]

public indirect enum TransformerPattern {
    case tree(TransformerPatternTree)
    // TODO case series
    case literal(String)
    case capture(TransformerCaptureName)
    
    func findCaptures<T>(for transformable: Transformable<T>) -> TransformerCaptures<T>? {
        switch (self, transformable) {
        case let (.capture(name), _):
            return [name: transformable]
        case (.tree, .leaf):
            return nil
        case let (.tree(pattern), .tree(transformable)):
            return mergedCaptures(patternTree: pattern, transformableTree: transformable)
        case let(.literal(expected), .leaf(.raw(actual))):
            return expected == actual ? [:] : nil
        case (.literal, _):
            return nil
        }
    }
    
    private func mergedCaptures<T>(patternTree: TransformerPatternTree, transformableTree: TransformableTree<T>) -> TransformerCaptures<T>? {
        guard Array(patternTree.keys) == Array(transformableTree.keys) else { return nil }
        let captures = transformableTree.flatMap { key, subTransformable in
            patternTree[key]?.findCaptures(for: subTransformable)
        }
        guard captures.count == patternTree.count else { return nil }
        return captures.reduce([:], +)
    }
}



// Tranformer rules

public typealias TransformerReducer<T> = (TransformerReducerArguments<T>) throws -> T?

public struct TransformerRule<T> {
    let pattern: TransformerPattern
    let reducer: TransformerReducer<T>
    
    public init(pattern: TransformerPattern, reducer: @escaping TransformerReducer<T>) {
        self.pattern = pattern
        self.reducer = reducer
    }
    
    func apply(to transformable: Transformable<T>) throws -> Transformable<T>? {
        guard let captures = pattern.findCaptures(for: transformable) else { return nil }
        let caps = TransformerReducerArguments(captures: captures)
        guard let reduced = try reducer(caps) else { return nil }
        return .leaf(TransformableLeaf.transformed(reduced))
    }
}



// Transformer

public class Transformer<T> {
    
    var rules: [TransformerRule<T>]
    
    public init(rules: [TransformerRule<T>] = []) {
       self.rules = rules
    }
    
    public func transform(_ tree: TransformerPatternTree, reducer: @escaping TransformerReducer<T>) {
        let pattern = TransformerPattern.tree(tree)
        let rule = TransformerRule<T>(pattern: pattern, reducer: reducer)
        rules.append(rule)
    }
    
    public func transform(pattern: TransformerPattern, reducer: @escaping TransformerReducer<T>) {
        let rule = TransformerRule<T>(pattern: pattern, reducer: reducer)
        rules.append(rule)
    }
    
    public func transform(_ resultWithRemainder: ResultWithRemainder) throws -> T {
        let (ist, _) = resultWithRemainder
        let transformable = try makeTransformable(for: ist)
        let result = try transform(transformable: transformable, rules: rules)
        guard case let .leaf(.transformed(value)) = result else { throw TransformerError.transformFailed(result) }
        return value
    }
    
    private func makeTransformable(for ist: Result) throws -> Transformable<T> {
        
        switch ist {
        case .failure:
            throw TransformerError<T>.inputNotTransformable(ist)
        case let .match(value, _):
            return .leaf(.raw(value))
        case let .tagged(tree):
            let transformables = try tree.mapValues { value in
                try makeTransformable(for: value)
            }
            return .tree(transformables)
        case .series:
            // TODO
            throw TransformerError<T>.inputNotTransformable(ist)
        }
    }
    
    private func transform(transformable: Transformable<T>, rules: [TransformerRule<T>]) throws -> Transformable<T> {
        
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
    
    private func apply(rules: [TransformerRule<T>], to transformable: Transformable<T>) throws -> Transformable<T> {
        for rule in rules {
            if let result = try rule.apply(to: transformable) {
                return result
            }
        }
        return transformable
    }
}
