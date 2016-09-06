import XCTest

class SequenceTests: XCTestCase {

    func test_twoPatternsMatchInputPrefix_sequenceMatches() {

        let sequence = Parser.Sequence(Parser.Str("abcd"), Parser.Str("efg"))

        let (actualResult, actualRemainder) = sequence.parse("abcdefghij")

        let expectedResult = Result.Match(match: "abcdefg", index: 0)
        let expectedRemainder = Remainder(text: "hij", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_twoPatternsMatchInputExactly_sequenceMatches() {

        let sequence = Parser.Sequence(Parser.Str("abc"), Parser.Str("def"))

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let expectedResult = Result.Match(match: "abcdef", index: 0)
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_firstElementDoesNotMatchInput_sequenceDoesNotMatch() {

        let first = Parser.Str("abc")
        let second = Parser.Str("def")

        let (actualResult, actualRemainder) = Parser.Sequence(first, second).parse("zdef")

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "zdef", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_secondElementDoesNotMatchInput_sequenceDoesNotMatch() {

        let first = Parser.Str("abc")
        let second = Parser.Str("def")

        let (actualResult, actualRemainder) = Parser.Sequence(first, second).parse("abcz")

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "z", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceTaggedFollowedBySeriesOfTagged_returnsSeriesOfTagged() {

        let one = Parser.Str("1")
        let two = Parser.Str("2")
        let repeatedOnes = Parser.Repeat(Parser.Tag("o", one), minimum: 1, maximum: nil)
        let someOnes = Parser.Tag("ones", repeatedOnes)
        let someTwos = Parser.Repeat(Parser.Tag("t", two), minimum: 1, maximum: nil)
        let someOnesAndTwos = Parser.Sequence(someOnes, someTwos)

        let (actualResult, actualRemainder) = someOnesAndTwos.parse("1122b")

        let taggedMatch0 = Result.Tagged(["o": Result.Match(match: "1", index: 0)])
        let taggedMatch1 = Result.Tagged(["o": Result.Match(match: "1", index: 1)])
        let taggedOnes = Result.Tagged(["ones": Result.Series([taggedMatch0, taggedMatch1])])
        let taggedMatch2 = Result.Tagged(["t": Result.Match(match: "2", index: 2)])
        let taggedMatch3 = Result.Tagged(["t": Result.Match(match: "2", index: 3)])
        let expectedResult = Result.Series([taggedOnes, taggedMatch2, taggedMatch3])
        let expectedRemainder = Remainder(text: "b", index: 4)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
