import XCTest
import Syft

class RepeatTests: XCTestCase {
    
    func test_repeatMinimum1_withoutMatch_fails() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: 1)
        
        let actual = repeat.parse("b")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatMinimum1_withMatch_matches() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: 1)
        
        let actual = repeat.parse("a")
        
        let expected = Result.Match(match: "a", index: 0, remainder: Remainder(text: "", index: 1))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatMinimum2_withoutEnoughMatches_fails() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 2, maximum: 2)
        
        let actual = repeat.parse("ab")
        
        let expected = Result.Failure
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatMinimum2_with2Matches_matches() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 2, maximum: 2)
        
        let actual = repeat.parse("aa")
        
        let expected = Result.Match(match: "aa", index: 0, remainder: Remainder(text: "", index: 2))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatMinimum0_withoutMatch_matches() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: 0)
        
        let actual = repeat.parse("bb")
        
        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "bb", index: 0))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatWithSuitableInput_matchesUpToMaximumTimes() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: 5)
        
        let actual = repeat.parse("aaaaaaaa")
        
        let expected = Result.Match(match: "aaaaa", index: 0, remainder: Remainder(text: "aaa", index: 5))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatInputHasMatchesBetweenMinimumAndMaximum_matches() {
        
        let strA = Syft.Match("a")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: 3)
        
        let actual = repeat.parse("aa")
        
        let expected = Result.Match(match: "aa", index: 0, remainder: Remainder(text: "", index: 2))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat0or1_input0_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: 1)
        
        let actual = repeat.parse("def")
        
        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "def", index: 0))
        XCTAssertEqual(expected, actual)
    }

    func test_repeat0or1_input1_matches() {

        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: 1)

        let actual = repeat.parse("abcdef")

        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat1orMore_input1_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: -1)
        
        let actual = repeat.parse("abcdef")
        
        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat1orMore_input10_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 1, maximum: -1)
        
        let actual = repeat.parse("abcabcabcabcabcabcabcabcabcabcdef")
        
        let expected = Result.Match(match: "abcabcabcabcabcabcabcabcabcabc", index: 0, remainder: Remainder(text: "def", index: 30))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat0orMore_input0_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: -1)
        
        let actual = repeat.parse("def")
        
        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "def", index: 0))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat0orMore_input1_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: -1)
        
        let actual = repeat.parse("abcdef")
        
        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeat0orMore_input10_matches() {
        
        let strA = Syft.Match("abc")
        let repeat = Syft.Repeat(strA, minimum: 0, maximum: -1)
        
        let actual = repeat.parse("abcabcabcabcabcabcabcabcabcabcdef")
        
        let expected = Result.Match(match: "abcabcabcabcabcabcabcabcabcabc", index: 0, remainder: Remainder(text: "def", index: 30))
        XCTAssertEqual(expected, actual)
    }
    
    func test_repeatNamedElements_returnsArrayOfHashes() {
        
        let strA = Syft.Match("a")
        let namedA = Syft.Name("anA", strA)
        let repeat = Syft.Repeat(namedA, minimum: 2, maximum: 2)
        
        let actual = repeat.parse("aa")
        
        let string1 = Result.Match(match: "a", index: 0, remainder: Remainder(text: "a", index: 1))
        let string2 = Result.Match(match: "a", index: 1, remainder: Remainder(text: "", index: 2))
        let hash1 = Result.Hash(["anA": string1], remainder: Remainder(text: "a", index: 1))
        let hash2 = Result.Hash(["anA": string2], remainder: Remainder(text: "", index: 2))
        let expected = Result.Array([hash1, hash2], remainder: Remainder(text: "", index: 2))
        XCTAssertEqual(expected, actual)
    }
}
