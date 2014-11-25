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
    
    func test_matchPrefix_returnsTrue() {
        
        var actual = Syft.Match("abc").parse("abcdef")
        XCTAssertTrue(actual)
    }
    
    func test_emptyPattern_matchesAnyInput() {
        
        var actual = Syft.Match("").parse("abc")
        XCTAssertTrue(actual)
    }
}
