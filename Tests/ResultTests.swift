import XCTest
import Syft

class ResultTests: XCTestCase {

    func test_descriptionFailure() {

        let result = Result.Failure

        XCTAssertEqual("<failure>", "\(result)")
    }

    func test_descriptionMatch() {

        let result = Result.Match(match: "abc", index: 5)

        XCTAssertEqual("\"abc\"@5", "\(result)")
    }

    func test_descriptionTagged() {

        let match1 = Result.Match(match: "abc", index: 5)
        let match2 = Result.Match(match: "zz", index: 10)
        let result = Result.Tagged(["symbol": match1, "another": match2])

        XCTAssertEqual("[another: \(match2), symbol: \(match1)]", "\(result)")
    }

    func test_descriptionSeries() {

        let match1 = Result.Match(match: "abc", index: 5)
        let match2 = Result.Match(match: "zz", index: 10)
        let result = Result.Series([match1, match2])

        XCTAssertEqual("[\(match1), \(match2)]", "\(result)")
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

    func test_sameTagged_equal() {

        let match = Result.Match(match: "aaa", index: 10)
        let left = Result.Tagged(["symbol": match])
        let right = Result.Tagged(["symbol": match])

        XCTAssertEqual(left, right)
    }

    func test_taggedWithDifferentNames_unequal() {

        let match = Result.Match(match: "aaa", index: 10)
        let left = Result.Tagged(["symbol": match])
        let right = Result.Tagged(["other": match])

        XCTAssertNotEqual(left, right)
    }

    func test_taggedWithDifferentMatches_unequal() {

        let leftMatch = Result.Match(match: "bbb", index: 10)
        let rightMatch = Result.Match(match: "aaa", index: 10)
        let left = Result.Tagged(["symbol": leftMatch])
        let right = Result.Tagged(["symbol": rightMatch])

        XCTAssertNotEqual(left, right)
    }

    func test_taggedWithExtraElementsOnLeft_unequal() {

        let match1 = Result.Match(match: "aaa", index: 10)
        let match2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Tagged(["symbol": match1, "symbol2": match2])
        let right = Result.Tagged(["symbol": match1])

        XCTAssertNotEqual(left, right)
    }

    func test_taggedWithExtraElementsOnRight_unequal() {

        let match1 = Result.Match(match: "aaa", index: 10)
        let match2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Tagged(["symbol": match1])
        let right = Result.Tagged(["symbol": match1, "symbol2": match2])

        XCTAssertNotEqual(left, right)
    }

    func test_taggedWithMultipleMatchingElements_equal() {

        let leftMatch1 = Result.Match(match: "aaa", index: 10)
        let leftMatch2 = Result.Match(match: "bbb", index: 10)
        let rightMatch1 = Result.Match(match: "aaa", index: 10)
        let rightMatch2 = Result.Match(match: "bbb", index: 10)
        let left = Result.Tagged(["symbol": leftMatch1, "symbol2": leftMatch2])
        let right = Result.Tagged(["symbol": rightMatch1, "symbol2": rightMatch2])

        XCTAssertEqual(left, right)
    }

}
