import XCTest
@testable import Syft

class MatchTests: XCTestCase {

    func test_emptyPatternAndInput_matches() {
    }

    func test_anySingleCharacter_matches() {

        let any = Parser.any

        let (actualResult, actualRemainder) = any.parse("abc")

        let expectedResult = Result.match(match: "a", index: 0)
        let expectedRemainder = Remainder(text: "bc", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_emptyInput_fails() {

        let any = Parser.any

        let (actualResult, actualRemainder) = any.parse("")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
