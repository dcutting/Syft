import XCTest
import Syft

class DeferredTests: XCTestCase {

    func test_deferredCanDirectlyParseAString() {
        let ampersand = Deferred()
        ampersand.parser = Parser.Str("&")

        // Act.
        let (actualResult, actualRemainder) = ampersand.parse("&")

        let expectedResult = Result.Match(match: "&", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_deferredHasNoParserSet_fails() {
        let deferred = Deferred()
        let parser = Parser.Defer(deferred)
        let anyString = "abc"

        // Act.
        let (actualResult, actualRemainder) = parser.parse(anyString)

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: anyString, index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_deferredParserHasBeenSet_returnsResultOfDeferred() {
        let ampersand = Deferred()
        let parser = Parser.Defer(ampersand)
        ampersand.parser = Parser.Str("&")

        // Act.
        let input = "&"
        let (actualResult, actualRemainder) = parser.parse(input)

        let expectedResult = Result.Match(match: "&", index: 0)
        let expectedRemainder = Remainder(text: "", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
