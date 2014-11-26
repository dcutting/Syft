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

    func test_sameSuccessResults_equal() {
        
        let left = MatchResult.Success(match: "def", remainder: "abc")
        let right = MatchResult.Success(match: "def", remainder: "abc")
        
        XCTAssertEqual(left, right)
    }

    func test_successWithDifferentRemainder_unequal() {
        
        let left = MatchResult.Success(match: "aaa", remainder: "abc")
        let right = MatchResult.Success(match: "aaa", remainder: "def")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentMatch_unequal() {
        
        let left = MatchResult.Success(match: "aaa", remainder: "abc")
        let right = MatchResult.Success(match: "bbb", remainder: "abc")
        
        XCTAssertNotEqual(left, right)
    }
}
