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
        
        let match1 = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        let match2 = Result.Match(match: "zz", index: 10, remainder: Remainder(text: "aaa", index: 5))
        let leaf = Result.Leaf(["symbol": match1, "another": match2], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual("[another: \(match2), symbol: \(match1)]", "\(leaf)")
    }
    
    func test_twoFailures_equal() {
        
        let left = Result.Failure
        let right = Result.Failure
        
        XCTAssertEqual(left, right)
    }

    func test_sameMatches_equal() {
        
        let left = Result.Match(match: "def", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "def", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertEqual(left, right)
    }

    func test_matchesWithDifferentRemainders_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "def", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_matchesWithDifferentText_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "bbb", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_matchesWithDifferentIndices_unequal() {
        
        let left = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let right = Result.Match(match: "aaa", index: 5, remainder: Remainder(text: "abc", index: 0))
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_sameLeafs_equal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": match], remainder: remainder)
        let right = Result.Leaf(["symbol": match], remainder: remainder)
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafsWithDifferentNames_unequal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": match], remainder: remainder)
        let right = Result.Leaf(["other": match], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafsWithDifferentMatches_unequal() {
        
        let leftMatch = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": leftMatch], remainder: remainder)
        let right = Result.Leaf(["symbol": rightMatch], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafsWithExtraElementsOnLeft_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let match2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": match1, "symbol2": match2], remainder: remainder)
        let right = Result.Leaf(["symbol": match1], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_leafsWithExtraElementsOnRight_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let match2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": match1], remainder: remainder)
        let right = Result.Leaf(["symbol": match1, "symbol2": match2], remainder: remainder)

        XCTAssertNotEqual(left, right)
    }
    
    func test_leafWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Leaf(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: remainder)
        let right = Result.Leaf(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: remainder)
        
        XCTAssertEqual(left, right)
    }
    
    func test_leafsWithDifferentRemainders_unequal() {
        
        let leftMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftRemainder = Remainder(text: "remainder", index: 5)
        let rightRemainder = Remainder(text: "other", index: 5)
        let left = Result.Leaf(["symbol": leftMatch], remainder: leftRemainder)
        let right = Result.Leaf(["symbol": rightMatch], remainder: rightRemainder)
        
        XCTAssertNotEqual(left, right)
    }
}
