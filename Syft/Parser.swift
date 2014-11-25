public protocol SyftLike {}

public enum Syft: SyftLike {
    case Match(String)
    case Sequence(SyftLike, SyftLike)
    
    public func parse(input: String) -> Bool {
        switch self {
            
        case let .Match(pattern):
            return pattern.isEmpty || input.hasPrefix(pattern)

        case let .Sequence(first, second):
            return true

        }
    }
}
