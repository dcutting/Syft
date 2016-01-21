import XCTest
import Syft

//class RepeatTests: XCTestCase {
//    
//    func test_repeatMinimum1_withoutMatch_fails() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 1, maximum: 1)
//        
//        let actual = repeated.parse("b")
//        
//        let expected = Result.Failure
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatMinimum1_withMatch_matches() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 1, maximum: 1)
//        
//        let actual = repeated.parse("a")
//        
//        let expected = Result.Match(match: "a", index: 0, remainder: Remainder(text: "", index: 1))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatMinimum2_withoutEnoughMatches_fails() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 2, maximum: 2)
//        
//        let actual = repeated.parse("ab")
//        
//        let expected = Result.Failure
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatMinimum2_with2Matches_matches() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 2, maximum: 2)
//        
//        let actual = repeated.parse("aa")
//        
//        let expected = Result.Match(match: "aa", index: 0, remainder: Remainder(text: "", index: 2))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatMinimum0_withoutMatch_matches() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 0)
//        
//        let actual = repeated.parse("bb")
//        
//        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "bb", index: 0))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatWithSuitableInput_matchesUpToMaximumTimes() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 5)
//        
//        let actual = repeated.parse("aaaaaaaa")
//        
//        let expected = Result.Match(match: "aaaaa", index: 0, remainder: Remainder(text: "aaa", index: 5))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatInputHasMatchesBetweenMinimumAndMaximum_matches() {
//        
//        let strA = Parser.Str("a")
//        let repeated = Parser.Repeat(strA, minimum: 1, maximum: 3)
//        
//        let actual = repeated.parse("aa")
//        
//        let expected = Result.Match(match: "aa", index: 0, remainder: Remainder(text: "", index: 2))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat0or1_input0_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 1)
//        
//        let actual = repeated.parse("def")
//        
//        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "def", index: 0))
//        XCTAssertEqual(expected, actual)
//    }
//
//    func test_repeat0or1_input1_matches() {
//
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 1)
//
//        let actual = repeated.parse("abcdef")
//
//        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat1orMore_input1_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 1, maximum: -1)
//        
//        let actual = repeated.parse("abcdef")
//        
//        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat1orMore_input10_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 1, maximum: -1)
//        
//        let actual = repeated.parse("abcabcabcabcabcabcabcabcabcabcdef")
//        
//        let expected = Result.Match(match: "abcabcabcabcabcabcabcabcabcabc", index: 0, remainder: Remainder(text: "def", index: 30))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat0orMore_input0_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: -1)
//        
//        let actual = repeated.parse("def")
//        
//        let expected = Result.Match(match: "", index: 0, remainder: Remainder(text: "def", index: 0))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat0orMore_input1_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: -1)
//        
//        let actual = repeated.parse("abcdef")
//        
//        let expected = Result.Match(match: "abc", index: 0, remainder: Remainder(text: "def", index: 3))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeat0orMore_input10_matches() {
//        
//        let strA = Parser.Str("abc")
//        let repeated = Parser.Repeat(strA, minimum: 0, maximum: -1)
//        
//        let actual = repeated.parse("abcabcabcabcabcabcabcabcabcabcdef")
//        
//        let expected = Result.Match(match: "abcabcabcabcabcabcabcabcabcabc", index: 0, remainder: Remainder(text: "def", index: 30))
//        XCTAssertEqual(expected, actual)
//    }
//    
//    func test_repeatNamedElements_returnsArrayOfHashes() {
//        
//        let strA = Parser.Str("a")
//        let namedA = Parser.Name("anA", strA)
//        let repeated = Parser.Repeat(namedA, minimum: 2, maximum: 2)
//        
//        let actual = repeated.parse("aa")
//        
//        let string1 = Result.Match(match: "a", index: 0, remainder: Remainder(text: "a", index: 1))
//        let string2 = Result.Match(match: "a", index: 1, remainder: Remainder(text: "", index: 2))
//        let hash1 = Result.Tagged(["anA": string1], remainder: Remainder(text: "a", index: 1))
//        let hash2 = Result.Tagged(["anA": string2], remainder: Remainder(text: "", index: 2))
//        let expected = Result.Series([hash1, hash2], remainder: Remainder(text: "", index: 2))
//        XCTAssertEqual(expected, actual)
//    }
//}
