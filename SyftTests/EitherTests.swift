import XCTest
import Syft

class EitherTests: XCTestCase {
    
    func test_eitherFailureAnything_fails() {
        
        let either = Parser.Either(Parser.Str("a"), Parser.Str("b"))
        
        let (actualResult, actualRemainder) = either.parse("c")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "c", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
