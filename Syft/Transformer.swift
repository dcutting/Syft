import Foundation



// Transformable data structure

public enum Leaf<T> {
    case transformed(T)
    case raw(String)
}

public indirect enum Transformable<T> {
    case tree([String: Transformable<T>])
    case leaf(Leaf<T>)
}



// Transformer patterns

public typealias CaptureName = String

public typealias Captures<T> = [CaptureName: Transformable<T>]

public indirect enum TransformerPattern {
    case tree([String: TransformerPattern])
    case capture(CaptureName)
    
    func matches<T>(transformable: Transformable<T>) -> Captures<T>? {
        
        return nil
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
}



// Transformer

public enum TransformerError: Error {
    case error
}

public class Transformer<T> {
    
    public init() {}
    
    public func transform(transformable: Transformable<T>, rules: [Rule<T>]) throws -> Transformable<T> {
        
        switch transformable {
        case let .tree(tree):
            var transformed: [String: Transformable<T>] = [:]
            for (key, value) in tree {
                let transformedValue = try transform(transformable: value, rules: rules)
                transformed[key] = transformedValue
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
            guard let captures = rule.pattern.matches(transformable: transformable) else { continue }
            switch rule.reducer(captures) {
            case let .success(reduced):
                return .leaf(.transformed(reduced))
            case .noMatch:
                continue
            case .unexpected:
                throw TransformerError.error
            }
        }
        return transformable
    }
}







//{
//
//    public func transform(ist: Transformable<T>, rules: [Rule<T>]) throws -> Transformable<T> {
//    
//        switch ist {
//        case let .tree(tree):
//            let transformed = tree.map({ (key, value) -> Transformable<T> in
//                let transformed = try! transform(ist: value, rules: rules)
//                return transformed
//            })
//            return try apply(rules: rules, to: transformed)
//        default:
//            throw TransformerError.error
//        }
//    }
//    
//    private func apply(rules: [Rule<T>], to: [Transformable<T>]) throws -> Transformable<T> {
//        let rule = rules.first { (rule) -> Bool in
//            switch rule.pattern {
//            case .capture:
//                throw TransformerError.error
//            case let .tree(tree):
//                
//            }
//        }
//    }
//}
//
//
//
//
////99 == transform(ist: ist, rules: [intRule, opRule])
//
////["left": ["int": "91"], "op": "+", "right": ["int": "8"]]
////["left": 91, "op": "+", "right": ["int": "8"]]
////["left": 91, "op": "+", "right": 8]
////99
////    
////    .tree(["left": .tree(["int": .leaf("91")], "op": .leaf("+"), "right": .tree(["int": .leaf("8")])])
////        .tree(["left": .transformed(91), "op": .leaf("+"), "right": .tree(["int": .leaf("8")])])
////        .tree(["left": .transformed(91), "op": .leaf("+"), "right": .transformed(8)])
////        .transformed(99)
////
//
//
//
//
//
////public enum Partial<T> {
////    case transformed(T)
////    case capture(String)
////}
////
////typealias Context<T> = [String: Partial<T>]
////
////public enum Pattern {
////    case simple(String)
////    case tree([String: Pattern])
////    
////    func apply<T>(to result: Result) -> Context<T> {
////        switch (self, result) {
////        case let (.simple(name), .match(match, _)):
////            return [name: Partial.capture(match)]
////        case let (.tree(patterns), .tagged(tags)):
////            var merged: Context<T> = [:]
////            for (key, subpattern) in patterns {
////                let subtree = tags[key]!
////                let context: Context<T> = subpattern.apply(to: subtree)
////                merged = mergeContexts(a: merged, b: context)
////            }
////        }
////    }
////}
////
////private func mergeContexts<T>(a: Context<T>, b: Context<T>) -> Context<T> {
////    var merged: Context<T> = [:]
////    for (k, v) in a {
////        merged[k] = v
////    }
////    for (k, v) in b {
////        merged[k] = v
////    }
////    return merged
////}
////
////public struct Rule<T> {
////    let pattern: Pattern
////    let action: (Context<T>) throws -> T
////}
////
////public enum TransformerError: Error {
////    case failure
////}
////
////public class Transformer<T> {
////    
////    var rules = [Rule<T>]()
////    
////    public init() {}
////    
////    public func append(_ rule: Rule<T>) {
////        rules.append(rule)
////    }
////    
////    public func transform(_ result: Result) throws -> T {
////        for rule in rules {
////            if let transformed = try apply(rule, to: result) {
////                return transformed
////            }
////        }
////        throw TransformerError.failure
////    }
////
////    func apply(_ rule: Rule<T>, to result: Result) throws -> T? {
////        switch (rule.pattern, result) {
////        case let (.simple(name), .match(match, _)):
////            let context = [name: match]
////            return try rule.action(context)
////        case let (.tree(patterns), .tagged(tags)):
////            var context = [String: T]()
////            for (key, subpattern) in patterns {
////                let value = tags[key]!
////                context[key] = try transform(value)
////            }
////            return try rule.action(context)
////        default:
////            return nil
////        }
////    }
////}
