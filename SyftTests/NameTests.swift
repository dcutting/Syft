import XCTest
import Syft

class NameTests: XCTestCase {
    
    func test_nameFailure() {
        
        let actual = Syft.Name("number", Syft.Match("563")).parse("123")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_nameMatch() {
        
        let actual = Syft.Name("number", Syft.Match("563")).parse("563")
        
        let match = Result.Match(match: "563", index: 0, remainder: "")
        let expected = Result.Leaf(["number": match], remainder: "")
        XCTAssertEqual(expected, actual)
    }
    
    func test_nameInnerName() {
        
        let innerName = Syft.Name("number", Syft.Match("563"))
        let outerName = Syft.Name("outer", innerName)
        
        let actual = outerName.parse("563")
        
        let match = Result.Match(match: "563", index: 0, remainder: "")
        let innerResult = Result.Leaf(["number": match], remainder: "")
        let expected = Result.Leaf(["outer": innerResult], remainder: "")
        XCTAssertEqual(expected, actual)
    }
    
    func test_nameSequenceOfMatches() {
        
        let seq = Syft.Sequence(Syft.Match("abc"), Syft.Match("def"))
        let actual = Syft.Name("alphabet", seq).parse("abcdef")
        
        let match = Result.Match(match: "abcdef", index: 0, remainder: "")
        let expected = Result.Leaf(["alphabet": match], remainder: "")
        XCTAssertEqual(expected, actual)
    }

    func test_nameSequenceWithNameOnLeft() {
        
        let innerName = Syft.Name("prefix", Syft.Match("abc"))
        let seq = Syft.Sequence(innerName, Syft.Match("def"))

        let actual = seq.parse("abcdef")
        
        let match = Result.Match(match: "abc", index: 0, remainder: "def")
        let expected = Result.Leaf(["prefix": match], remainder: "")
        XCTAssertEqual(expected, actual)
    }
}
