extension String {

    func split(at index: String.Index) -> (String, String) {

        let head = self[self.startIndex..<index]
        let tail = self[index..<self.endIndex]

        return (head, tail)
    }

    func indented(by: Int) -> String {
        guard by > 0 else { return self }
        return (" " + self).indented(by: by-1)
    }
}
