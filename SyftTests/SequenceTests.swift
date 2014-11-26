import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_bothElementsMatchInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")

        let actual = Syft.Sequence(first, second).parse("abcdefghi")

        let expected = MatchResult.Success(match: "abcdef", remainder: "ghi")
        XCTAssertEqual(expected, actual)
    }
    
    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("zdef")
        
        let expected = MatchResult.Failure(remainder: "zdef")
        XCTAssertEqual(expected, actual)
    }
}
