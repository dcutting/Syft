extension String {

    func split(at index: Int) -> (String, String) {

        let head = self.prefix(index)
        let tail = self.dropFirst(index)

        return (String(head), String(tail))
    }

    func indented(by: Int) -> String {
        guard by > 0 else { return self }
        return (" " + self).indented(by: by-1)
    }
}
