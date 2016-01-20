import XCTest
import Syft

class NameTests: XCTestCase {
    
    func test_strFails_nameFails() {
        
        let (actualResult, actualRemainder) = Parser.Name("number", Parser.Str("563")).parse("123")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "123", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_strSucceeds_nameSucceeds() {
        
        let (actualResult, actualRemainder) = Parser.Name("number", Parser.Str("563")).parse("563")
        
        let match = Result.Match(match: "563", index: 0)
        let expectedResult = Result.Hash(["number": match])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_nestedNamesSucceeds_nameSucceeds() {
        
        let innerName = Parser.Name("number", Parser.Str("563"))
        let outerName = Parser.Name("outer", innerName)
        
        let (actualResult, actualRemainder) = outerName.parse("563")
        
        let match = Result.Match(match: "563", index: 0)
        let innerResult = Result.Hash(["number": match])
        let expectedResult = Result.Hash(["outer": innerResult])
        let expectedRemainder = Remainder(text: "", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_sequenceOfStrsSucceeds_nameSucceeds() {
        
        let sequence = Parser.Sequence(Parser.Str("abc"), Parser.Str("def"))
        let (actualResult, actualRemainder) = Parser.Name("alphabet", sequence).parse("abcdef")
        
        let match = Result.Match(match: "abcdef", index: 0)
        let expectedResult = Result.Hash(["alphabet": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_sequenceWithNestedNameOnLeftSucceeds_unnamedMatchesOmitted() {
        
        let innerName = Parser.Name("prefix", Parser.Str("abc"))
        let sequence = Parser.Sequence(innerName, Parser.Str("def"))

        let (actualResult, actualRemainder) = sequence.parse("abcdef")
        
        let match = Result.Match(match: "abc", index: 0)
        let expectedResult = Result.Hash(["prefix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_sequenceWithNestedNameOnRightSucceeds_unnamedMatchesOmitted() {
        
        let innerName = Parser.Name("suffix", Parser.Str("def"))
        let sequence = Parser.Sequence(Parser.Str("abc"), innerName)
        
        let (actualResult, actualRemainder) = sequence.parse("abcdef")
        
        let match = Result.Match(match: "def", index: 3)
        let expectedResult = Result.Hash(["suffix": match])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_sequenceWithTwoNestedNames_bothLeavesReturned() {
        
        let leftInnerName = Parser.Name("prefix", Parser.Str("abc"))
        let rightInnerName = Parser.Name("suffix", Parser.Str("def"))
        let sequence = Parser.Sequence(leftInnerName, rightInnerName)
        
        let (actualResult, actualRemainder) = sequence.parse("abcdef")
        
        let leftMatch = Result.Match(match: "abc", index: 0)
        let rightMatch = Result.Match(match: "def", index: 3)
        let expectedResult = Result.Hash(["prefix": leftMatch, "suffix": rightMatch])
        let expectedRemainder = Remainder(text: "", index: 6)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_namedSequenceWithNestedName_innerHashWrappedInOuterHash() {
        
        let innerName = Parser.Name("suffix", Parser.Str("efg"))
        let sequence = Parser.Sequence(Parser.Str("abcd"), innerName)
        
        let nameSequence = Parser.Name("total", sequence)
        let (actualResult, actualRemainder) = nameSequence.parse("abcdefg")
        
        let innerMatch = Result.Match(match: "efg", index: 4)
        let innerResult = Result.Hash(["suffix": innerMatch])
        let expectedResult = Result.Hash(["total": innerResult])
        let expectedRemainder = Remainder(text: "", index: 7)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
