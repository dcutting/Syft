public struct Remainder: Equatable {

    let text: String
    let index: Int

    public static func == (lhs: Remainder, rhs: Remainder) -> Bool {
        return lhs.text == rhs.text && lhs.index == rhs.index
    }
}