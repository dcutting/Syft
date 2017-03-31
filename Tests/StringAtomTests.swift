import XCTest

class StringAtomTests: XCTestCase {

    func test_emptyPatternAndInput_matches() {

        let (actualResult, actualRemainder) = Parser.str("").parse("")

        let expectedResult = Result.match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_differentPatternAndInput_fails() {

        let (actualResult, actualRemainder) = Parser.str("abc").parse("def")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "def", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_inputWithPrefixMatchingPattern_matches() {

        let (actualResult, actualRemainder) = Parser.str("abc").parse("abcdef")

        let expectedResult = Result.match(match: "abc", index: 0)
        let expectedRemainder = Remainder(text: "def", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_emptyPatternAnyInput_matches() {

        let (actualResult, actualRemainder) = Parser.str("").parse("abc")

        let expectedResult = Result.match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "abc", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
