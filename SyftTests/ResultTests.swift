import XCTest
import Syft

class ResultTests: XCTestCase {
    
    func test_descriptionFailure() {
        
        let result = Result.Failure
        XCTAssertEqual("<failure>", "\(result)")
    }
    
    func test_descriptionMatch() {
        
        let match = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        XCTAssertEqual("\"abc\"@5[def:0]", "\(match)")
    }
    
    func test_descriptionHash() {
        
        let match1 = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        let match2 = Result.Match(match: "zz", index: 10, remainder: Remainder(text: "aaa", index: 5))
        let hash = Result.Hash(["symbol": match1, "another": match2], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual("[another: \(match2), symbol: \(match1)]", "\(hash)")
    }
    
    func test_descriptionArray() {
        
        let match1 = Result.Match(match: "abc", index: 5, remainder: Remainder(text: "def", index: 0))
        let match2 = Result.Match(match: "zz", index: 10, remainder: Remainder(text: "aaa", index: 5))
        let array = Result.Array([match1, match2], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual("[\(match1), \(match2)][:0]", "\(array)")
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
    
    func test_sameHashes_equal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": match], remainder: remainder)
        let right = Result.Hash(["symbol": match], remainder: remainder)
        
        XCTAssertEqual(left, right)
    }
    
    func test_hashesWithDifferentNames_unequal() {
        
        let match = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": match], remainder: remainder)
        let right = Result.Hash(["other": match], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithDifferentMatches_unequal() {
        
        let leftMatch = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": leftMatch], remainder: remainder)
        let right = Result.Hash(["symbol": rightMatch], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithExtraElementsOnLeft_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let match2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": match1, "symbol2": match2], remainder: remainder)
        let right = Result.Hash(["symbol": match1], remainder: remainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithExtraElementsOnRight_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let match2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": match1], remainder: remainder)
        let right = Result.Hash(["symbol": match1, "symbol2": match2], remainder: remainder)

        XCTAssertNotEqual(left, right)
    }
    
    func test_hashWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch1 = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch2 = Result.Match(match: "bbb", index: 10, remainder: Remainder(text: "abc", index: 0))
        let remainder = Remainder(text: "", index: 0)
        let left = Result.Hash(["symbol": leftMatch1, "symbol2": leftMatch2], remainder: remainder)
        let right = Result.Hash(["symbol": rightMatch1, "symbol2": rightMatch2], remainder: remainder)
        
        XCTAssertEqual(left, right)
    }
    
    func test_hashesWithDifferentRemainders_unequal() {
        
        let leftMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let rightMatch = Result.Match(match: "aaa", index: 10, remainder: Remainder(text: "abc", index: 0))
        let leftRemainder = Remainder(text: "remainder", index: 5)
        let rightRemainder = Remainder(text: "other", index: 5)
        let left = Result.Hash(["symbol": leftMatch], remainder: leftRemainder)
        let right = Result.Hash(["symbol": rightMatch], remainder: rightRemainder)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_twoEmptyArraysAndSameRemainder_equal() {
        
        let left = Result.Array([], remainder: Remainder(text: "", index: 0))
        let right = Result.Array([], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual(left, right)
    }
    
    func test_twoEmptyArraysAndDifferentRemainder_unequal() {
        
        let left = Result.Array([], remainder: Remainder(text: "hi", index: 0))
        let right = Result.Array([], remainder: Remainder(text: "", index: 0))
        XCTAssertNotEqual(left, right)
    }
    
    func test_twoSameArraysAndSameRemainders_equal() {
        
        let resultA = Result.Match(match: "hello", index: 5, remainder: Remainder(text: "", index: 10))
        let resultB = Result.Match(match: "hello", index: 5, remainder: Remainder(text: "", index: 10))
        let left = Result.Array([resultA, resultB], remainder: Remainder(text: "", index: 0))
        let right = Result.Array([resultA, resultB], remainder: Remainder(text: "", index: 0))
        XCTAssertEqual(left, right)
    }
}
