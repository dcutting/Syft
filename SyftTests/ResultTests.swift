import XCTest
import Syft

class ResultTests: XCTestCase {
    
    func test_descriptionFailure() {
        
        let result = Result.Failure
        
        XCTAssertEqual("<failure>", "\(result)")
    }
    
    func test_descriptionMatch() {
        
        let match = Result.Match(match: "abc", index: 5)
        
        XCTAssertEqual("\"abc\"@5", "\(match)")
    }
    
    func test_descriptionHash() {
        
        let match1 = Result.Match(match: "abc", index: 5)
        let match2 = Result.Match(match: "zz", index: 10)
        let hash = Result.Hash(["symbol": match1, "another": match2])
        
        XCTAssertEqual("[another: \(match2), symbol: \(match1)]", "\(hash)")
    }
    
    func test_descriptionArray() {
        
        let match1 = Result.Match(match: "abc", index: 5)
        let match2 = Result.Match(match: "zz", index: 10)
        let array = Result.Array([match1, match2])
        
        XCTAssertEqual("[\(match1), \(match2)]", "\(array)")
    }
    
    func test_twoFailures_equal() {
        
        let left = Result.Failure
        let right = Result.Failure
        
        XCTAssertEqual(left, right)
    }

    func test_sameMatches_equal() {
        
        let left = Result.Match(match: "def", index: 5)
        let right = Result.Match(match: "def", index: 5)
        
        XCTAssertEqual(left, right)
    }

    func test_matchesWithDifferentText_unequal() {
        
        let left = Result.Match(match: "aaa", index: 5)
        let right = Result.Match(match: "bbb", index: 5)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_matchesWithDifferentIndices_unequal() {
        
        let left = Result.Match(match: "aaa", index: 10)
        let right = Result.Match(match: "aaa", index: 5)
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_sameHashes_equal() {
        
        let match = Result.Match(match: "aaa", index: 10)
        let left = Result.Hash(["symbol": match])
        let right = Result.Hash(["symbol": match])
        
        XCTAssertEqual(left, right)
    }
    
    func test_hashesWithDifferentNames_unequal() {
        
        let match = Result.Match(match: "aaa", index: 10)
        let left = Result.Hash(["symbol": match])
        let right = Result.Hash(["other": match])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithDifferentMatches_unequal() {
        
        let leftMatch = Result.Match(match: "bbb", index: 10)
        let rightMatch = Result.Match(match: "aaa", index: 10)
        let left = Result.Hash(["symbol": leftMatch])
        let right = Result.Hash(["symbol": rightMatch])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithExtraElementsOnLeft_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10)
        let match2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Hash(["symbol": match1, "symbol2": match2])
        let right = Result.Hash(["symbol": match1])
        
        XCTAssertNotEqual(left, right)
    }
    
    func test_hashesWithExtraElementsOnRight_unequal() {
        
        let match1 = Result.Match(match: "aaa", index: 10)
        let match2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Hash(["symbol": match1])
        let right = Result.Hash(["symbol": match1, "symbol2": match2])

        XCTAssertNotEqual(left, right)
    }
    
    func test_hashWithMultipleMatchingElements_equal() {
        
        let leftMatch1 = Result.Match(match: "aaa", index: 10)
        let leftMatch2 = Result.Match(match: "bbb", index: 10)
        let rightMatch1 = Result.Match(match: "aaa", index: 10)
        let rightMatch2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Hash(["symbol": leftMatch1, "symbol2": leftMatch2])
        let right = Result.Hash(["symbol": rightMatch1, "symbol2": rightMatch2])
        
        XCTAssertEqual(left, right)
    }
}
