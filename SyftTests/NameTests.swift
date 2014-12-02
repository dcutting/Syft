import XCTest
import Syft

class NameTests: XCTestCase {
    
    func test_nameMatch() {
        
        let actual = Syft.Name("number", Syft.Match("563")).parse("563")
        
        let match = MatchResult.Match(match: "563", index: 0, remainder: "")
        let expected = MatchResult.Leaf(["number": match])
        XCTAssertEqual(expected, actual)
    }
    
    func test_nameFailure() {
        
        let actual = Syft.Name("number", Syft.Match("563")).parse("123")
        
        let match = MatchResult.Failure
        let expected = MatchResult.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_nameSequence() {
        
        let seq = Syft.Sequence(Syft.Match("abc"), Syft.Match("def"))
        let actual = Syft.Name("alphabet", seq).parse("abcdef")
        
        let match = MatchResult.Match(match: "abcdef", index: 0, remainder: "")
        let expected = MatchResult.Leaf(["alphabet": match])
        XCTAssertEqual(expected, actual)
    }
}
