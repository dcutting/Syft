import Foundation


// Errors

public enum TransformerError<T>: Error {
    case inputInvalid(Result)
    case unexpectedRemainder(Remainder)
    case transformFailed(Transformable<T>)
    case reducerFailed(Transformable<T>, TransformerPattern, TransformerCaptures<T>)
    case unknownCaptureVariable(TransformerCaptureName)
    case captureVariableUnexpectedlyRaw(TransformerCaptureName)
    case captureVariableUnexpectedlyTransformed(TransformerCaptureName)
    case untransformedSequence(TransformerCaptureName)
}



// Transformable data structure

public enum TransformableLeaf<T> {
    case transformed(T)
    case raw(String)
}

public typealias TransformableTree<T> = [String: Transformable<T>]

public typealias TransformableSeries<T> = [Transformable<T>]

public indirect enum Transformable<T> {
    case tree(TransformableTree<T>)
    case series(TransformableSeries<T>)
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

    public func val(_ key: String) throws -> T {
        return try transformed(key)
    }

    public func vals(_ key: String) throws -> [T] {
        let value = try get(key: key)
        guard case let .series(transformable) = value else {
            throw TransformerError<T>.captureVariableUnexpectedlyRaw(key)
        }
        let result = try transformable.map { t -> T in
            if case let .leaf(.transformed(leaf)) = t {
                return leaf
            }
            throw TransformerError<T>.untransformedSequence(key)
        }
        return result
    }

    public func str(_ key: String) throws -> String {
        let value = try get(key: key)
        guard case let .leaf(.raw(raw)) = value else {
            throw TransformerError<T>.captureVariableUnexpectedlyTransformed(key)
        }
        return raw
    }

    public func strs(_ key: String) throws -> [String] {
        let value = try get(key: key)
        guard case let .series(transformable) = value else {
            throw TransformerError<T>.captureVariableUnexpectedlyRaw(key)
        }
        let result = try transformable.map { t -> String in
            if case let .leaf(.raw(leaf)) = t {
                return leaf
            }
            throw TransformerError<T>.untransformedSequence(key)
        }
        return result
    }

    private func get(key: String) throws -> Transformable<T> {
        guard let value = captures[key] else { throw TransformerError<T>.unknownCaptureVariable(key) }
        return value
    }
}

public typealias TransformerPatternTree = [String: TransformerPattern]
public typealias TransformerPatternSeries = [TransformerPattern]

public indirect enum TransformerPattern {
    case tree(TransformerPatternTree)
    case series(String)
    case literal(String)
    case simple(TransformerCaptureName)
    // TODO case capture subtree

    func findCaptures<T>(for transformable: Transformable<T>) -> TransformerCaptures<T>? {
        switch (self, transformable) {
        case let (.simple(name), .leaf):
            return [name: transformable]
        case let (.tree(pattern), .tree(transformable)):
            return mergedCaptures(patternTree: pattern, transformableTree: transformable)
        case let (.series(name), .series):
            return [name: transformable]
        case let (.literal(expected), .leaf(.raw(actual))):
            return expected == actual ? [:] : nil
        case (.simple, _),
             (.tree, _),
             (.series, _),
             (.literal, _):
            return nil
        }
    }

    private func mergedCaptures<T>(patternTree: TransformerPatternTree, transformableTree: TransformableTree<T>) -> TransformerCaptures<T>? {
        guard Set(patternTree.keys) == Set(transformableTree.keys) else { return nil }
        let captures = transformableTree.flatMap { args in
            patternTree[args.key]?.findCaptures(for: args.value)
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

open class Transformer<T> {

    fileprivate var rules: [TransformerRule<T>]

    public init(rules: [TransformerRule<T>] = []) {
        self.rules = rules
    }

    public func transform(_ resultWithRemainder: ResultWithRemainder) throws -> T {
        let (ist, remainder) = resultWithRemainder
        guard remainder.text.isEmpty else { throw TransformerError<T>.unexpectedRemainder(remainder) }
        let transformable = try makeTransformable(for: ist)
        let result = try transform(transformable: transformable, rules: rules)
        guard case let .leaf(.transformed(value)) = result else { throw TransformerError.transformFailed(result) }
        return value
    }

    private func makeTransformable(for ist: Result) throws -> Transformable<T> {

        switch ist {
        case .failure:
            throw TransformerError<T>.inputInvalid(ist)
        case let .match(value, _):
            return .leaf(.raw(value))
        case let .tagged(tree):
            let transformables = try tree.mapValues { value in
                try makeTransformable(for: value)
            }
            return .tree(transformables)
        case let .series(results):
            let transformables = try results.map { value in
                try makeTransformable(for: value)
            }
            return .series(transformables)
        case let .maybe(result):
            let transformable = try makeTransformable(for: result)
            return .series([transformable])
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
        case let .series(series):
            let transformed = try series.map { value in
                try transform(transformable: value, rules: rules)
            }
            let transformedSeries = Transformable.series(transformed)
            return try apply(rules: rules, to: transformedSeries)
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

public extension Transformer {   // Convenience

    public func rule(_ tree: TransformerPatternTree, reducer: @escaping TransformerReducer<T>) {
        let pattern = TransformerPattern.tree(tree)
        rule(pattern: pattern, reducer: reducer)
    }

    public func rule(pattern: TransformerPattern, reducer: @escaping TransformerReducer<T>) {
        let rule = TransformerRule<T>(pattern: pattern, reducer: reducer)
        rules.append(rule)
    }
}
