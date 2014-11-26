import XCTest
import Syft

class MatchResultTests: XCTestCase {
    
    func test_failuresWithDifferentRemainder_unequal() {
        
        let left = MatchResult.Failure(remainder: "abc")
        let right = MatchResult.Failure(remainder: "def")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_failuresWithSameRemainder_equal() {
        
        let left = MatchResult.Failure(remainder: "abc")
        let right = MatchResult.Failure(remainder: "abc")
        
        XCTAssertEqual(left, right)
    }

    func test_successWithSameRemainder_equal() {
        
        let left = MatchResult.Success(remainder: "abc")
        let right = MatchResult.Success(remainder: "abc")
        
        XCTAssertEqual(left, right)
    }

    func test_successWithDifferentRemainder_unequal() {
        
        let left = MatchResult.Success(remainder: "abc")
        let right = MatchResult.Success(remainder: "def")
        
        XCTAssertNotEqual(left, right)
    }
}
