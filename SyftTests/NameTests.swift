import XCTest
import Syft

class NameTests: XCTestCase {
    
    func test_nameMatch() {
        
        let actual = Syft.Name("number", Syft.Match("563")).parse("563")
        
        let match = MatchResult.Match(match: "563", index: 0, remainder: "")
        let expected = MatchResult.Leaf(name: "number", match: match)
        XCTAssertEqual(expected, actual)
    }
}
