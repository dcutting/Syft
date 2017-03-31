import XCTest

class TagTests: XCTestCase {

    func test_strFails_tagFails() {

        let (actualResult, actualRemainder) = Parser.tagged("number", Parser.str("563")).parse("123")

        let expectedResult = Result.failure
        let expectedRemainder = Remainder(text: "123", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_strSucceeds_tagSucceeds() {

        let (actualResult, actualRemainder) = Parser.tagged("number", Parser.str("563")).parse("563")

        let match = Result.match(match: "563", index: 0)
        let expectedResult = Result.tagged(["number": match])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_nestedTagsSucceeds_tagSucceeds() {

        let innerTag = Parser.tagged("number", Parser.str("563"))
        let outerTag = Parser.tagged("outer", innerTag)

        let (actualResult, actualRemainder) = outerTag.parse("563")

        let match = Result.match(match: "563", index: 0)
        let innerResult = Result.tagged(["number": match])
        let expectedResult = Result.tagged(["outer": innerResult])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceOfStrsSucceeds_tagSucceeds() {

        let sequence = Parser.sequence(Parser.str("abc"), Parser.str("def"))
        let (actualResult, actualRemainder) = Parser.tagged("alphabet", sequence).parse("abcdef")

        let match = Result.match(match: "abcdef", index: 0)
        let expectedResult = Result.tagged(["alphabet": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithNestedTagOnLeftSucceeds_untaggedMatchesOmitted() {

        let innerTag = Parser.tagged("prefix", Parser.str("abc"))
        let sequence = Parser.sequence(innerTag, Parser.str("def"))

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let match = Result.match(match: "abc", index: 0)
        let expectedResult = Result.tagged(["prefix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithNestedTagOnRightSucceeds_untaggedMatchesOmitted() {

        let innerTag = Parser.tagged("suffix", Parser.str("def"))
        let sequence = Parser.sequence(Parser.str("abc"), innerTag)

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let match = Result.match(match: "def", index: 3)
        let expectedResult = Result.tagged(["suffix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithTwoNestedTags_bothLeavesReturned() {

        let leftInnerTag = Parser.tagged("prefix", Parser.str("abc"))
        let rightInnerTag = Parser.tagged("suffix", Parser.str("def"))
        let sequence = Parser.sequence(leftInnerTag, rightInnerTag)

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let leftMatch = Result.match(match: "abc", index: 0)
        let rightMatch = Result.match(match: "def", index: 3)
        let expectedResult = Result.tagged(["prefix": leftMatch, "suffix": rightMatch])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_taggedSequenceWithNestedTag_innerTaggedWrappedInOuterTagged() {

        let innerTag = Parser.tagged("suffix", Parser.str("efg"))
        let sequence = Parser.sequence(Parser.str("abcd"), innerTag)

        let tagSequence = Parser.tagged("total", sequence)
        let (actualResult, actualRemainder) = tagSequence.parse("abcdefg")

        let innerMatch = Result.match(match: "efg", index: 4)
        let innerResult = Result.tagged(["suffix": innerMatch])
        let expectedResult = Result.tagged(["total": innerResult])
        let expectedRemainder = Remainder(text: "", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
