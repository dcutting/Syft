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
}
