import XCTest
import Syft

class DeferredTests: XCTestCase {
    
    func test_deferredHasNoParserSet_fails() {
        let deferred = DeferredParser(name: "deferred")
        let parser = Parser.Deferred(deferred)
        let anyString = "abc"
        
        // Act.
        let (actualResult, actualRemainder) = parser.parse(anyString)
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: anyString, index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_deferredParserHasBeenSet_returnsResultOfDeferredParser() {
        let ampersand = DeferredParser(name: "ampersand")
        let parser = Parser.Deferred(ampersand)
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
