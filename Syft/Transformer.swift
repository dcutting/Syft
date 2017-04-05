import Foundation

public indirect enum Transformed<T> {
    case transformed(T)
    case value(String)
    case series([Transformed<T>])
    case tree([String: Transformed<T>])
}

public enum Pattern {
    case literal(String)
    case value(String)
    case transformed(String)
}

public struct Transformation<T> {
    let from: [String: Pattern]
    let to: ([String: Transformed<T>]) -> T
    
    init(from: [String: Pattern], to: @escaping ([String: Transformed<T>]) -> T) {
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
    
    public func transform(_ resultWithRemainder: ResultWithRemainder) throws -> T {
        
        let (result, _) = resultWithRemainder
        
        let initial = try convert(result)
        
        print(initial)
        
        let final = applyTransformations(to: initial)
        
        print(final)
    
        switch final {
        case let .transformed(root):
            return root
        default:
            throw TransformerError.failure
        }
    }
    
    func convert(_ result: Result) throws -> Transformed<T> {
        switch result {
        case .failure:
            throw TransformerError.failure
        case let .match(match: match, index: _):
            return .value(match)
        case .tagged(let tags):
            var next = [String: Transformed<T>]()
            do {
                for (key, value) in tags {
                    next[key] = try convert(value)
                }
                return .tree(next)
            } catch {
                throw error
            }
        case .series(let series):
            return .series(try series.map { try convert($0) })
        }
    }
    
    func applyTransformations(to partial: Transformed<T>) -> Transformed<T> {
        
        switch partial {
        case .transformed, .value:
            return partial
        case .tree:
            break
        case .series:
            break
        }
        
        for rule in transformations {
            if let transformed = apply(transformation: rule, to: partial) {
                return transformed
            }
        }
        
        return partial
    }
    
    func apply(transformation: Transformation<T>, to partial: Transformed<T>) -> Transformed<T>? {
        return nil
    }
}
