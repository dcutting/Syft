import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
    func test_transformLiteral_strings() {
        
        let result = Result.match(match: "hello", index: any())
        
        let transformer = Transformer<String>()
        
        let rule = Rule.literal("hello") { _ in "world" }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual("world", transformed)
    }
    
    func test_transformLiteral_capturesValue() {
        
        let result = Result.match(match: "99", index: any())
        
        let transformer = Transformer<Int>()
        
        let rule = Rule.literal("99") { Int($0).map { $0 + 1 } }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual(100, transformed)
    }
}
