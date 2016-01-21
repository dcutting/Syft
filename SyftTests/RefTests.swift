import XCTest
import Syft

class RefTests: XCTestCase {
    
    func test_refDoesNotExist_fails() {
        let parser = Parser.Ref("nosuchref")
        let anyString = "abc"
        
        let (actualResult, actualRemainder) = parser.parse(anyString)
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: anyString, index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
