import XCTest

class EitherTests: XCTestCase {

    func test_bothSubparsersFail_eitherFails() {

        let either = Parser.either(Parser.str("a"), Parser.str("b"))

        let (actualResult, actualRemainder) = either.parse("c")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "c", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstSubparserMatches_eitherMatches() {

        let either = Parser.either(Parser.str("a"), Parser.str("b"))

        let (actualResult, actualRemainder) = either.parse("a")

        let expectedResult = Result.match(match: "a", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstSubparserFailsButSecondMatches_eitherMatches() {

        let either = Parser.either(Parser.str("a"), Parser.str("b"))

        let (actualResult, actualRemainder) = either.parse("b")

        let expectedResult = Result.match(match: "b", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
