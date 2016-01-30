import XCTest
import Syft

class MatchTests: XCTestCase {
    
    func test_emptyPatternAndInput_matches() {
    }
    
    func test_anySingleCharacter_matches() {
        
        let any = Parser.Any

        let (actualResult, actualRemainder) = any.parse("abc")
        
        let expectedResult = Result.Match(match: "a", index: 0)
        let expectedRemainder = Remainder(text: "bc", index: 1)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_emptyInput_fails() {
        
        let any = Parser.Any
        
        let (actualResult, actualRemainder) = any.parse("")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
