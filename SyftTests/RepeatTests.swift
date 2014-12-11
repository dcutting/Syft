import XCTest
import Syft

class RepeatTests: XCTestCase {
    
    func test_repeatMinimum1_withoutMatch_fails() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: 1)
        
        let actual = repeat.parse("b")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatMinimum1_withMatch_matches() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: 1)
        
        let actual = repeat.parse("a")
        
        let expected = Result.Match(match: "a", index: 0, remainder: Remainder(text: "", index: 1))
        XCTAssertEqual(expected, actual)
    }
}
