public enum Syft {
    case Match(String)
    
    public func parse(input: String) -> Bool {
        switch self {
        case let .Match(pattern):
            return input == pattern || input.hasPrefix(pattern)
        }
    }
}
