import XCTest
import Syft

class EitherTests: XCTestCase {

    func test_bothSubparsersFail_eitherFails() {

        let either = Parser.Either(Parser.Str("a"), Parser.Str("b"))

        let (actualResult, actualRemainder) = either.parse("c")

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "c", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstSubparserMatches_eitherMatches() {

        let either = Parser.Either(Parser.Str("a"), Parser.Str("b"))

        let (actualResult, actualRemainder) = either.parse("a")

        let expectedResult = Result.Match(match: "a", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstSubparserFailsButSecondMatches_eitherMatches() {

        let either = Parser.Either(Parser.Str("a"), Parser.Str("b"))

        let (actualResult, actualRemainder) = either.parse("b")

        let expectedResult = Result.Match(match: "b", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
