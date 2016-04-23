import XCTest
import Syft

class TagTests: XCTestCase {

    func test_strFails_tagFails() {

        let (actualResult, actualRemainder) = Parser.Tag("number", Parser.Str("563")).parse("123")

        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "123", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_strSucceeds_tagSucceeds() {

        let (actualResult, actualRemainder) = Parser.Tag("number", Parser.Str("563")).parse("563")

        let match = Result.Match(match: "563", index: 0)
        let expectedResult = Result.Tagged(["number": match])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_nestedTagsSucceeds_tagSucceeds() {

        let innerTag = Parser.Tag("number", Parser.Str("563"))
        let outerTag = Parser.Tag("outer", innerTag)

        let (actualResult, actualRemainder) = outerTag.parse("563")

        let match = Result.Match(match: "563", index: 0)
        let innerResult = Result.Tagged(["number": match])
        let expectedResult = Result.Tagged(["outer": innerResult])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceOfStrsSucceeds_tagSucceeds() {

        let sequence = Parser.Sequence(Parser.Str("abc"), Parser.Str("def"))
        let (actualResult, actualRemainder) = Parser.Tag("alphabet", sequence).parse("abcdef")

        let match = Result.Match(match: "abcdef", index: 0)
        let expectedResult = Result.Tagged(["alphabet": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithNestedTagOnLeftSucceeds_untaggedMatchesOmitted() {

        let innerTag = Parser.Tag("prefix", Parser.Str("abc"))
        let sequence = Parser.Sequence(innerTag, Parser.Str("def"))

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let match = Result.Match(match: "abc", index: 0)
        let expectedResult = Result.Tagged(["prefix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithNestedTagOnRightSucceeds_untaggedMatchesOmitted() {

        let innerTag = Parser.Tag("suffix", Parser.Str("def"))
        let sequence = Parser.Sequence(Parser.Str("abc"), innerTag)

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let match = Result.Match(match: "def", index: 3)
        let expectedResult = Result.Tagged(["suffix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithTwoNestedTags_bothLeavesReturned() {

        let leftInnerTag = Parser.Tag("prefix", Parser.Str("abc"))
        let rightInnerTag = Parser.Tag("suffix", Parser.Str("def"))
        let sequence = Parser.Sequence(leftInnerTag, rightInnerTag)

        let (actualResult, actualRemainder) = sequence.parse("abcdef")

        let leftMatch = Result.Match(match: "abc", index: 0)
        let rightMatch = Result.Match(match: "def", index: 3)
        let expectedResult = Result.Tagged(["prefix": leftMatch, "suffix": rightMatch])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_taggedSequenceWithNestedTag_innerTaggedWrappedInOuterTagged() {

        let innerTag = Parser.Tag("suffix", Parser.Str("efg"))
        let sequence = Parser.Sequence(Parser.Str("abcd"), innerTag)

        let tagSequence = Parser.Tag("total", sequence)
        let (actualResult, actualRemainder) = tagSequence.parse("abcdefg")

        let innerMatch = Result.Match(match: "efg", index: 4)
        let innerResult = Result.Tagged(["suffix": innerMatch])
        let expectedResult = Result.Tagged(["total": innerResult])
        let expectedRemainder = Remainder(text: "", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

}
