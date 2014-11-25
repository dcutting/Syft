public enum Syft {
    case Match(String)
    
    public func parse(input: String) -> Bool {
        switch self {
        case let .Match(pattern):
            return pattern.isEmpty || input.hasPrefix(pattern)
        }
    }
}
