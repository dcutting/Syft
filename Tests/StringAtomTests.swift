import XCTest

class StringAtomTests: XCTestCase {

    func test_emptyPatternAndInput_matches() {

        let (actualResult, actualRemainder) = Parser.Str("").parse("")

        let expectedResult = Result.Match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_differentPatternAndInput_fails() {

        let (actualResult, actualRemainder) = Parser.Str("abc").parse("def")

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "def", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_inputWithPrefixMatchingPattern_matches() {

        let (actualResult, actualRemainder) = Parser.Str("abc").parse("abcdef")

        let expectedResult = Result.Match(match: "abc", index: 0)
        let expectedRemainder = Remainder(text: "def", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_emptyPatternAnyInput_matches() {

        let (actualResult, actualRemainder) = Parser.Str("").parse("abc")

        let expectedResult = Result.Match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "abc", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
