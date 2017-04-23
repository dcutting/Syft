extension Dictionary {

    func sortedDescription() -> String {
        
        let joined = map { key, value in "\(key): \(value)" }.sorted().joined(separator: ", ")

        return "[\(joined)]"
    }

    func mapValues<T>(_ transformer: (Value) throws -> T) rethrows -> Dictionary<Key, T> {
        var transformed: Dictionary<Key, T> = [:]
        for (key, value) in self {
            transformed[key] = try transformer(value)
        }
        return transformed
    }
}

func + <K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {

    var map = Dictionary<K, V>()

    for (k, v) in left {
        map[k] = v
    }

    for (k, v) in right {
        map[k] = v
    }

    return map
}
