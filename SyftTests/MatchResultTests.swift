import XCTest
import Syft

class MatchResultTests: XCTestCase {
    
    func test_descriptionFailure() {
        
        let match = MatchResult.Failure
        XCTAssertEqual("<failure>", "\(match)")
    }
    
    func test_descriptionMatch() {
        
        let match = MatchResult.Match(match: "abc", index: 5, remainder: "def")
        XCTAssertEqual("\"abc\"@5", "\(match)")
    }
    
    func test_descriptionLeaf() {
        
        let match = MatchResult.Match(match: "abc", index: 5, remainder: "def")
        let leaf = MatchResult.Leaf(["symbol": match])
        XCTAssertEqual("[symbol: \"abc\"@5]", "\(leaf)")
    }
    
    func test_twoFailures_equal() {
        
        let left = MatchResult.Failure
        let right = MatchResult.Failure
        
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
    
    func test_successWithDifferentIndex_unequal() {
        
        let left = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let right = MatchResult.Match(match: "aaa", index: 5, remainder: "abc")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithSameNamesAndMatches_equal() {
        
        let match = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let left = MatchResult.Leaf(["symbol": match])
        let right = MatchResult.Leaf(["symbol": match])
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafWithDifferentNamesAndMatches_unequal() {
        
        let leftMatch = MatchResult.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let left = MatchResult.Leaf(["symbol": leftMatch])
        let right = MatchResult.Leaf(["symbol": rightMatch])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnLeft_unequal() {
        
        let leftMatch1 = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let leftMatch2 = MatchResult.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let left = MatchResult.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2])
        let right = MatchResult.Leaf(["symbol": rightMatch])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnRight_unequal() {
        
        let leftMatch = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch1 = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch2 = MatchResult.Match(match: "bbb", index: 10, remainder: "abc")
        let left = MatchResult.Leaf(["symbol": leftMatch])
        let right = MatchResult.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let leftMatch2 = MatchResult.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch1 = MatchResult.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch2 = MatchResult.Match(match: "bbb", index: 10, remainder: "abc")
        let left = MatchResult.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2])
        let right = MatchResult.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2])
        
        XCTAssertEqual(left, right)
    }
}
