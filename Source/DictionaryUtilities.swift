extension Dictionary {

    func sortedDescription() -> String {
        
        let joined = map { key, value in "\(key): \(value)" }.sorted().joined(separator: ", ")

        return "[\(joined)]"
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
