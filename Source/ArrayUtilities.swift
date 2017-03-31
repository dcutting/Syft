extension Array {

    var head: Element? {
        return self.first
    }

    var tail: Array<Element> {
        return count < 1 ? self : Array(self[1..<count])
    }
}

extension Array {

    func sortedDescription() -> String {

        let joined = self.map { "\($0)" }.sorted { $0 < $1 }.joined(separator: ", ")

        return "[\(joined)]"
    }

}
