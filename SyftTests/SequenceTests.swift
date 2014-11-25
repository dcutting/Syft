import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_bothElementsMatchInput_sequenceMatches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")

        let actual = Syft.Sequence(first, second).parse("abcdef")
        
        XCTAssertTrue(actual)
    }
    
    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")
        
        let actual = Syft.Sequence(first, second).parse("zdef")
        
        XCTAssertFalse(actual)
    }
}
