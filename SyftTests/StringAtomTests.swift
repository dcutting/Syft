import XCTest
import Syft

class StringAtomTests: XCTestCase {

    func test_matchEmptyString_returnsTrue() {
    
        var actual = Syft.Match("").parse("")
        XCTAssertTrue(actual)
    }
    
    func test_matchDifferentString_returnsFalse() {
        
        var actual = Syft.Match("abc").parse("def")
        XCTAssertFalse(actual)
    }
}
