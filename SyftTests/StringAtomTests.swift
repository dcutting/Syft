import XCTest
import Syft

class StringAtomTests: XCTestCase {

    func test_emptyTemplate_matchesEmptyInput() {
    
        let actual = Syft.Match("").parse("")
        
        let expected = MatchResult.Success(match: "", remainder: "")
        XCTAssertEqual(expected, actual)
    }
    
    func test_differentTemplateAndInput_doNotMatch() {
        
        let actual = Syft.Match("abc").parse("def")

        let expected = MatchResult.Failure(remainder: "def")
        XCTAssertEqual(expected, actual)
    }
    
    func test_templateMatchesInputWithSamePrefix() {
        
        let actual = Syft.Match("abc").parse("abcdef")
        
        let expected = MatchResult.Success(match: "abc", remainder: "def")
        XCTAssertEqual(expected, actual)
    }
    
    func test_emptyPattern_matchesAnyInput() {
        
        let actual = Syft.Match("").parse("abc")
        
        let expected = MatchResult.Success(match: "", remainder: "abc")
        XCTAssertEqual(expected, actual)
    }
}
