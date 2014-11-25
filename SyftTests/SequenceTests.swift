import XCTest
import Syft

class SequenceTests: XCTestCase {
    
    func test_twoAtoms_matches() {
        
        let first = Syft.Match("abc")
        let second = Syft.Match("def")

        let actual = Syft.Sequence(first, second).parse("abcdef")
        
        XCTAssertTrue(actual)
    }
}
