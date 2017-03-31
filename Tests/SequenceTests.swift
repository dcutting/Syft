import XCTest

class SequenceTests: XCTestCase {

    func test_twoPatternsMatchInputPrefix_sequenceMatches() {

        let sequence = Parser.sequence(Parser.str("abcd"), Parser.str("efg"))

        let (actualResult, actualRemainder) = sequence.parse("abcdefghij")

        let expectedResult = Result.match(match: "abcdefg", index: 0)
        let expectedRemainder = Remainder(text: "hij", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_twoPatternsMatchInputExactly_sequenceMatches() {

        let sequence = Parser.sequence(Parser.str("abc"), Parser.str("def"))

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let expectedResult = Result.match(match: "abcdef", index: 0)
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {

        let first = Parser.str("abc")
        let second = Parser.str("def")

        let (actualResult, actualRemainder) = Parser.sequence(first, second).parse("zdef")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "zdef", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_secondElementDoesNotMatchInput_sequenceDoesNotMatch() {

        let first = Parser.str("abc")
        let second = Parser.str("def")

        let (actualResult, actualRemainder) = Parser.sequence(first, second).parse("abcz")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "z", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceTaggedFollowedBySeriesOfTagged_returnsSeriesOfTagged() {

        let one = Parser.str("1")
        let two = Parser.str("2")
        let repeatedOnes = Parser.repeat(Parser.tagged("o", one), minimum: 1, maximum: nil)
        let someOnes = Parser.tagged("ones", repeatedOnes)
        let someTwos = Parser.repeat(Parser.tagged("t", two), minimum: 1, maximum: nil)
        let someOnesAndTwos = Parser.sequence(someOnes, someTwos)

        let (actualResult, actualRemainder) = someOnesAndTwos.parse("1122b")

        let taggedMatch0 = Result.tagged(["o": Result.match(match: "1", index: 0)])
        let taggedMatch1 = Result.tagged(["o": Result.match(match: "1", index: 1)])
        let taggedOnes = Result.tagged(["ones": Result.series([taggedMatch0, taggedMatch1])])
        let taggedMatch2 = Result.tagged(["t": Result.match(match: "2", index: 2)])
        let taggedMatch3 = Result.tagged(["t": Result.match(match: "2", index: 3)])
        let expectedResult = Result.series([taggedOnes, taggedMatch2, taggedMatch3])
        let expectedRemainder = Remainder(text: "b", index: 4)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
