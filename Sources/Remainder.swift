public struct Remainder: Equatable {

    public let text: String
    public let index: Int

    public static func == (lhs: Remainder, rhs: Remainder) -> Bool {
        return lhs.text == rhs.text && lhs.index == rhs.index
    }
}
