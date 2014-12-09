import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_twoPatternsMatchInputPrefix_sequenceMatches() {
        
        let sequence = Syft.Sequence(Syft.Match("abcd"), Syft.Match("efg"))

        let actual = sequence.parse("abcdefghij")

        let expected = Result.Match(match: "abcdefg", index: 0, remainder: Remainder(text: "hij", index: 7))
        XCTAssertEqual(expected, actual)
    }
    
    func test_twoPatternsMatchInputExactly_sequenceMatches() {
        
        let sequence = Syft.Sequence(Syft.Match("abc"), Syft.Match("def"))
        
        let actual = sequence.parse("abcdef")
        
        let expected = Result.Match(match: "abcdef", index: 0, remainder: Remainder(text: "", index: 6))
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
