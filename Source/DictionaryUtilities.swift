extension Dictionary {

    func sortedDescription() -> String {

        var pairs = Array<String>()
        for (key, value) in self {
            pairs.append("\(key): \(value)")
        }
        let joinedPairs = pairs.sort().joinWithSeparator(", ")

        return "[\(joinedPairs)]"
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
