import XCTest
import Syft

class ResultTests: XCTestCase {
    
    func test_descriptionFailure() {
        
        let match = Result.Failure
        XCTAssertEqual("<failure>", "\(match)")
    }
    
    func test_descriptionMatch() {
        
        let match = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        XCTAssertEqual("\"abc\"@5", "\(match)")
    }
    
    func test_descriptionLeaf() {
        
        let match = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        let leaf = Result.Leaf(["symbol": match, "another": match], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual("[another: \(match), symbol: \(match)]", "\(leaf)")
    }
    
    func test_twoFailures_equal() {
        
        let left = Result.Failure
        let right = Result.Failure
        
        XCTAssertEqual(left, right)
    }

    func test_sameSuccessResults_equal() {
        
        let left = Result.Match(match: "def", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "def", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertEqual(left, right)
    }

    func test_successWithDifferentRemainder_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "def", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentMatch_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "bbb", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_successWithDifferentIndex_unequal() {
        
        let left = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithSameNamesAndMatches_equal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let left = Result.Leaf(["symbol": match], remainder: Remainder(text: "", index: 0))
        let right = Result.Leaf(["symbol": match], remainder: Remainder(text: "", index: 0))
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafWithDifferentNamesAndMatches_unequal() {
        
        let leftMatch = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let left = Result.Leaf(["symbol": leftMatch], remainder: Remainder(text: "", index: 0))
        let right = Result.Leaf(["symbol": rightMatch], remainder: Remainder(text: "", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnLeft_unequal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let left = Result.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: Remainder(text: "", index: 0))
        let right = Result.Leaf(["symbol": rightMatch], remainder: Remainder(text: "", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithExtraElementsOnRight_unequal() {
        
        let leftMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let left = Result.Leaf(["symbol": leftMatch], remainder: Remainder(text: "", index: 0))
        let right = Result.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: Remainder(text: "", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let left = Result.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: Remainder(text: "", index: 0))
        let right = Result.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: Remainder(text: "", index: 0))
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafWithDifferentRemainders_unequal() {
        
        let leftMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftRemainder = Remainder(text: "remainder", index: 5)
        let rightRemainder = Remainder(text: "other", index: 5)
        let left = Result.Leaf(["symbol": leftMatch], remainder: leftRemainder)
        let right = Result.Leaf(["symbol": rightMatch], remainder: rightRemainder)
        
        XCTAssertNotEqual(left, right)
    }
}
