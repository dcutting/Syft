extension String {

    func splitAtIndex(_ index: String.Index) -> (String, String) {

        let head = self[self.startIndex..<index]
        let tail = self[index..<self.endIndex]

        return (head, tail)
    }

}
