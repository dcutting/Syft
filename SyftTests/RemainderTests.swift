import XCTest
import Syft

class RemainderTests: XCTestCase {
    
    func test_equal_equates() {
        
        let leftRemainder = Remainder(text: "abc", index: 5)
        let rightRemainder = Remainder(text: "abc", index: 5)
        
        XCTAssertEqual(leftRemainder, rightRemainder)
    }
    
    func test_differentText_doesNotEquate() {
        
        let leftRemainder = Remainder(text: "abc", index: 5)
        let rightRemainder = Remainder(text: "def", index: 5)
        
        XCTAssertNotEqual(leftRemainder, rightRemainder)
    }
    
    func test_differentIndex_doesNotEquate() {
        
        let leftRemainder = Remainder(text: "abc", index: 1)
        let rightRemainder = Remainder(text: "abc", index: 5)
        
        XCTAssertNotEqual(leftRemainder, rightRemainder)
    }
}
