import XCTest
import Syft

class StringAtomTests: XCTestCase {

    func test_emptyTemplate_matchesEmptyInput() {
    
        let actual = Syft.Match("").parse("")
        
        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "", index: 0))
        XCTAssertEqual(expected, actual)
    }
    
    func test_differentTemplateAndInput_doNotMatch() {
        
        let actual = Syft.Match("abc").parse("def")

        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_templateMatchesInputWithSamePrefix() {
        
        let actual = Syft.Match("abc").parse("abcdef")
        
        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_emptyPattern_matchesAnyInput() {
        
        let actual = Syft.Match("").parse("abc")
        
        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "abc", index: 0))
        XCTAssertEqual(expected, actual)
    }
}
