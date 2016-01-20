import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_twoPatternsMatchInputPrefix_sequenceMatches() {
        
        let sequence = Syft.Sequence(Syft.Str("abcd"), Syft.Str("efg"))

        let (actualResult, actualRemainder) = sequence.parse("abcdefghij")

        let expectedResult = Result.Match(match: "abcdefg", index: 0)
        let expectedRemainder = Remainder(text: "hij", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_twoPatternsMatchInputExactly_sequenceMatches() {
        
        let sequence = Syft.Sequence(Syft.Str("abc"), Syft.Str("def"))
        
        let (actualResult, actualRemainder) = sequence.parse("abcdef")
        
        let expectedResult = Result.Match(match: "abcdef", index: 0)
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Str("abc")
        let second = Syft.Str("def")
        
        let (actualResult, actualRemainder) = Syft.Sequence(first, second).parse("zdef")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "zdef", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_secondElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Str("abc")
        let second = Syft.Str("def")
        
        let (actualResult, actualRemainder) = Syft.Sequence(first, second).parse("abcz")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "z", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
