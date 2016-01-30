import XCTest
import Syft

class RepeatTests: XCTestCase {
    
    func test_repeatWithoutEnoughMatches_fails() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 3, maximum: nil)
        
        let (actualResult, actualRemainder) = repeated.parse("aab")
        
        let expectedResult = Result.Failure
        let expectedRemainder = Remainder(text: "aab", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_repeatWithEnoughMatches_returnsCombinedMatch() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 3, maximum: nil)
        
        let (actualResult, actualRemainder) = repeated.parse("aaaab")
        
        let expectedResult = Result.Match(match: "aaaa", index: 0)
        let expectedRemainder = Remainder(text: "b", index: 4)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatMatchesUpToMaximum_returnsRestAsRemainder() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 5)
        
        let (actualResult, actualRemainder) = repeated.parse("aaaaaaaa")
        
        let expectedResult = Result.Match(match: "aaaaa", index: 0)
        let expectedRemainder = Remainder(text: "aaa", index: 5)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_repeatDoesNotReachMaximum_returnsAsManyAsPossible() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 5)
        
        let (actualResult, actualRemainder) = repeated.parse("aaab")
        
        let expectedResult = Result.Match(match: "aaa", index: 0)
        let expectedRemainder = Remainder(text: "b", index: 3)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_repeatMinimum0_withoutMatch_returnsEmptyMatch() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 0, maximum: nil)
        
        let (actualResult, actualRemainder) = repeated.parse("bb")
        
        let expectedResult = Result.Match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "bb", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_repeatMinimum0maximum0_returnsEmptyMatch() {
        
        let strA = Parser.Str("a")
        let repeated = Parser.Repeat(strA, minimum: 0, maximum: 0)
        
        let (actualResult, actualRemainder) = repeated.parse("bb")
        
        let expectedResult = Result.Match(match: "", index: 0)
        let expectedRemainder = Remainder(text: "bb", index: 0)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }

    func test_repeatTag_returnsSeriesOfTags() {
        
        let strA = Parser.Tag("anA", Parser.Str("a"))
        let repeated = Parser.Repeat(strA, minimum: 1, maximum: nil)
        
        let (actualResult, actualRemainder) = repeated.parse("aab")
        
        let taggedMatch0 = Result.Tagged(["anA": Result.Match(match: "a", index: 0)])
        let taggedMatch1 = Result.Tagged(["anA": Result.Match(match: "a", index: 1)])
        let expectedResult = Result.Series([taggedMatch0, taggedMatch1])
        let expectedRemainder = Remainder(text: "b", index: 2)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
    
    func test_tagRepeatedTag_returnsTaggedSeriesOfTags() {
        
        let strA = Parser.Tag("anA", Parser.Str("a"))
        let repeated = Parser.Repeat(strA, minimum: 1, maximum: nil)
        let taggedRepeated = Parser.Tag("someAs", repeated)
        
        let (actualResult, actualRemainder) = taggedRepeated.parse("aab")
        
        let taggedMatch0 = Result.Tagged(["anA": Result.Match(match: "a", index: 0)])
        let taggedMatch1 = Result.Tagged(["anA": Result.Match(match: "a", index: 1)])
        let series = Result.Series([taggedMatch0, taggedMatch1])
        let expectedResult = Result.Tagged(["someAs": series])
        let expectedRemainder = Remainder(text: "b", index: 2)
        XCTAssertEqual(expectedResult, actualResult)
        XCTAssertEqual(expectedRemainder, actualRemainder)
    }
}
