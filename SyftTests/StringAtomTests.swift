import XCTest
import Syft

class StringAtomTests: XCTestCase {

    func testEmptyString() {
    
        var actual = Syft.Match("").parse("")
        XCTAssertTrue(actual)
    }
}
