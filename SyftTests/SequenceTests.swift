import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_bothElementsMatchPrefixOfInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")

        let actual = Syft.Sequence(first, second).parse("abcdefghi")

        let expected = Result.Match(match: "abcdef", index: 0, remainder: Remainder(text: "ghi", index: 0))
        XCTAssertEqual(expected, actual)
    }
    
    func test_bothElementsExactlyMatchInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("abcdef")
        
        let expected = Result.Match(match: "abcdef", index: 0, remainder: Remainder(text: "", index: 0))
        XCTAssertEqual(expected, actual)
    }
    
    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("zdef")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_secondElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("abcz")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
}
