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

        let joined = self.map { "\($0)" }.sort { $0 < $1 }.joinWithSeparator(", ")

        return "[\(joined)]"
    }

}
