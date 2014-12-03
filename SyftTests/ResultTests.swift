import XCTest
import Syft

class ResultTests: XCTestCase {
    
    func test_descriptionFailure() {
        
        let match = Result.Failure
        XCTAssertEqual("<failure>", "\(match)")
    }
    
    func test_descriptionMatch() {
        
        let match = Result.Match(match: "abc", index: 5, remainder: "def")
        XCTAssertEqual("\"abc\"@5", "\(match)")
    }
    
    func test_descriptionLeaf() {
        
        let match = Result.Match(match: "abc", index: 5, remainder: "def")
        let leaf = Result.Leaf(["symbol": match, "another": match], remainder: "")
        XCTAssertEqual("[another: \(match), symbol: \(match)]", "\(leaf)")
    }
    
    func test_twoFailures_equal() {
        
        let left = Result.Failure
        let right = Result.Failure
        
        XCTAssertEqual(left, right)
    }

    func test_sameSuccessResults_equal() {
        
        let left = Result.Match(match: "def", index: 5, remainder: "abc")
        let right = Result.Match(match: "def", index: 5, remainder: "abc")
        
        XCTAssertEqual(left, right)
    }

    func test_successWithDifferentRemainder_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: "abc")
        let right = Result.Match(match: "aaa", index: 5, remainder: "def")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentMatch_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: "abc")
        let right = Result.Match(match: "bbb", index: 5, remainder: "abc")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentIndex_unequal() {
        
        let left = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let right = Result.Match(match: "aaa", index: 5, remainder: "abc")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithSameNamesAndMatches_equal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let left = Result.Leaf(["symbol": match], remainder: "")
        let right = Result.Leaf(["symbol": match], remainder: "")
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafWithDifferentNamesAndMatches_unequal() {
        
        let leftMatch = Result.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let left = Result.Leaf(["symbol": leftMatch], remainder: "")
        let right = Result.Leaf(["symbol": rightMatch], remainder: "")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnLeft_unequal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let left = Result.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: "")
        let right = Result.Leaf(["symbol": rightMatch], remainder: "")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnRight_unequal() {
        
        let leftMatch = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: "abc")
        let left = Result.Leaf(["symbol": leftMatch], remainder: "")
        let right = Result.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: "")
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: "abc")
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: "abc")
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: "abc")
        let left = Result.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: "")
        let right = Result.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: "")
        
        XCTAssertEqual(left, right)
    }
}
