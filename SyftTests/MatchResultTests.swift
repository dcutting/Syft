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
        
        let left = MatchResult.Match(match: "def", index: 5, remainder: "abc")
        let right = MatchResult.Match(match: "def", index: 5, remainder: "abc")
        
        XCTAssertEqual(left, right)
    }

    func test_successWithDifferentRemainder_unequal() {
        
        let left = MatchResult.Match(match: "aaa", index: 5, remainder: "abc")
        let right = MatchResult.Match(match: "aaa", index: 5, remainder: "def")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentMatch_unequal() {
        
        let left = MatchResult.Match(match: "aaa", index: 5, remainder: "abc")
        let right = MatchResult.Match(match: "bbb", index: 5, remainder: "abc")
        
        XCTAssertNotEqual(left, right)
    }
}
