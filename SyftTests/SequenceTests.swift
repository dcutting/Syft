import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_bothElementsMatchPrefixOfInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")

        let actual = Syft.Sequence(first, second).parse("abcdefghi")

        let expected = MatchResult.Success(match: "abcdef", remainder: "ghi")
        XCTAssertEqual(expected, actual)
    }
    
    func test_bothElementsExactlyMatchInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("abcdef")
        
        let expected = MatchResult.Success(match: "abcdef", remainder: "")
        XCTAssertEqual(expected, actual)
    }
    
    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("zdef")
        
        let expected = MatchResult.Failure(remainder: "zdef")
        XCTAssertEqual(expected, actual)
    }
    
    func test_secondElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("abcz")
        
        let expected = MatchResult.Failure(remainder: "abcz")
        XCTAssertEqual(expected, actual)
    }
}
