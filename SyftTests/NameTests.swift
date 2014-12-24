import XCTest
import Syft

class NameTests: XCTestCase {
    
    func test_strFails_nameFails() {
        
        let actual = Syft.Name("number", Syft.Str("563")).parse("123")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_strSucceeds_nameSucceeds() {
        
        let actual = Syft.Name("number", Syft.Str("563")).parse("563")
        
        let match = Result.Match(match: "563", index: 0, remainder: Remainder(text: "", index: 3))
        let expected = Result.Hash(["number": match], remainder: Remainder(text: "", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_nestedNamesSucceeds_nameSucceeds() {
        
        let innerName = Syft.Name("number", Syft.Str("563"))
        let outerName = Syft.Name("outer", innerName)
        
        let actual = outerName.parse("563")
        
        let match = Result.Match(match: "563", index: 0, remainder: Remainder(text: "", index: 3))
        let innerResult = Result.Hash(["number": match], remainder: Remainder(text: "", index: 3))
        let expected = Result.Hash(["outer": innerResult], remainder: Remainder(text: "", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_sequenceOfStrsSucceeds_nameSucceeds() {
        
        let sequence = Syft.Sequence(Syft.Str("abc"), Syft.Str("def"))
        let actual = Syft.Name("alphabet", sequence).parse("abcdef")
        
        let match = Result.Match(match: "abcdef", index: 0, remainder: Remainder(text: "", index: 6))
        let expected = Result.Hash(["alphabet": match], remainder: Remainder(text: "", index: 6))
        XCTAssertEqual(expected, actual)
    }

    func test_sequenceWithNestedNameOnLeftSucceeds_unnamedMatchesOmitted() {
        
        let innerName = Syft.Name("prefix", Syft.Str("abc"))
        let sequence = Syft.Sequence(innerName, Syft.Str("def"))

        let actual = sequence.parse("abcdef")
        
        let match = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        let expected = Result.Hash(["prefix": match], remainder: Remainder(text: "", index: 6))
        XCTAssertEqual(expected, actual)
    }
    
    func test_sequenceWithNestedNameOnRightSucceeds_unnamedMatchesOmitted() {
        
        let innerName = Syft.Name("suffix", Syft.Str("def"))
        let sequence = Syft.Sequence(Syft.Str("abc"), innerName)
        
        let actual = sequence.parse("abcdef")
        
        let match = Result.Match(match: "def", index: 3, remainder: Remainder(text: "", index: 6))
        let expected = Result.Hash(["suffix": match], remainder: Remainder(text: "", index: 6))
        XCTAssertEqual(expected, actual)
    }
    
    func test_sequenceWithTwoNestedNames_bothLeavesReturned() {
        
        let leftInnerName = Syft.Name("prefix", Syft.Str("abc"))
        let rightInnerName = Syft.Name("suffix", Syft.Str("def"))
        let sequence = Syft.Sequence(leftInnerName, rightInnerName)
        
        let actual = sequence.parse("abcdef")
        
        let leftMatch = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        let rightMatch = Result.Match(match: "def", index: 3, remainder: Remainder(text: "", index: 6))
        let expected = Result.Hash(["prefix": leftMatch, "suffix": rightMatch], remainder: Remainder(text: "", index: 6))
        XCTAssertEqual(expected, actual)
    }
    
    func test_namedSequenceWithNestedName_innerHashWrappedInOuterHash() {
        
        let innerName = Syft.Name("suffix", Syft.Str("efg"))
        let sequence = Syft.Sequence(Syft.Str("abcd"), innerName)
        
        let nameSequence = Syft.Name("total", sequence)
        let actual = nameSequence.parse("abcdefg")
        
        let innerMatch = Result.Match(match: "efg", index: 4, remainder: Remainder(text: "", index: 7))
        let innerResult = Result.Hash(["suffix": innerMatch], remainder: Remainder(text: "", index: 7))
        let expected = Result.Hash(["total": innerResult], remainder: Remainder(text: "", index: 7))
        XCTAssertEqual(expected, actual)
    }
}
