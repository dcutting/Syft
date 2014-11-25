import XCTest
import Syft

class StringAtomTests: XCTestCase {

    func test_emptyTemplate_matchesEmptyInput() {
    
        var actual = Syft.Match("").parse("")
        XCTAssertTrue(actual)
    }
    
    func test_differentTemplateAndInput_doNotMatch() {
        
        var actual = Syft.Match("abc").parse("def")
        XCTAssertFalse(actual)
    }
    
    func test_templateMatchesInputWithSamePrefix() {
        
        var actual = Syft.Match("abc").parse("abcdef")
        XCTAssertTrue(actual)
    }
    
    func test_emptyPattern_matchesAnyInput() {
        
        var actual = Syft.Match("").parse("abc")
        XCTAssertTrue(actual)
    }
}
