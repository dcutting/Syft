import XCTest
@testable import Syft

class RepeatTests: XCTestCase {

    func test_repeatWithoutEnoughMatches_fails() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 3, maximum: nil)

        let (actualResult, actualRemainder) = repeated.parse("aab")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "aab", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatWithEnoughMatches_returnsCombinedMatch() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 3, maximum: nil)

        let (actualResult, actualRemainder) = repeated.parse("aaaab")

        let expectedResult = Result.match(match: "aaaa", index: 0)
        let expectedRemainder = Remainder(text: "b", index: 4)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatMatchesUpToMaximum_returnsRestAsRemainder() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 0, maximum: 5)

        let (actualResult, actualRemainder) = repeated.parse("aaaaaaaa")

        let expectedResult = Result.match(match: "aaaaa", index: 0)
        let expectedRemainder = Remainder(text: "aaa", index: 5)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatDoesNotReachMaximum_returnsAsManyAsPossible() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 0, maximum: 5)

        let (actualResult, actualRemainder) = repeated.parse("aaab")

        let expectedResult = Result.match(match: "aaa", index: 0)
        let expectedRemainder = Remainder(text: "b", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatMinimum0_withoutMatch_returnsEmptyMatch() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 0, maximum: nil)

        let (actualResult, actualRemainder) = repeated.parse("bb")

        let expectedResult = Result.match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "bb", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatMinimum0maximum0_returnsEmptyMatch() {

        let strA = Parser.str("a")
        let repeated = Parser.repeat(strA, minimum: 0, maximum: 0)

        let (actualResult, actualRemainder) = repeated.parse("bb")

        let expectedResult = Result.match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "bb", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatTag_returnsSeriesOfTags() {

        let strA = Parser.tagged("anA", Parser.str("a"))
        let repeated = Parser.repeat(strA, minimum: 1, maximum: nil)

        let (actualResult, actualRemainder) = repeated.parse("aab")

        let taggedMatch0 = Result.tagged(["anA": Result.match(match: "a", index: 0)])
        let taggedMatch1 = Result.tagged(["anA": Result.match(match: "a", index: 1)])
        let expectedResult = Result.series([taggedMatch0, taggedMatch1])
        let expectedRemainder = Remainder(text: "b", index: 2)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_tagRepeatedTag_returnsTaggedSeriesOfTags() {

        let strA = Parser.tagged("anA", Parser.str("a"))
        let repeated = Parser.repeat(strA, minimum: 1, maximum: nil)
        let taggedRepeated = Parser.tagged("someAs", repeated)

        let (actualResult, actualRemainder) = taggedRepeated.parse("aab")

        let taggedMatch0 = Result.tagged(["anA": Result.match(match: "a", index: 0)])
        let taggedMatch1 = Result.tagged(["anA": Result.match(match: "a", index: 1)])
        let series = Result.series([taggedMatch0, taggedMatch1])
        let expectedResult = Result.tagged(["someAs": series])
        let expectedRemainder = Remainder(text: "b", index: 2)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
