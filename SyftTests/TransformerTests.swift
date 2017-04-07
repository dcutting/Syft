import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
    func test_transformLiteral_strings() {
        
        let result = Result.match(match: "hello", index: any())
        
        let transformer = Transformer<String>()
        
        let rule = Rule.literal("hello") { "world" }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual("world", transformed)
    }
    
    func test_transformLiteral_ints() {
        
        let result = Result.match(match: "99", index: any())
        
        let transformer = Transformer<Int>()
        
        let rule = Rule.literal("99") { 100 }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual(100, transformed)
    }
    
    func test_transformSimple_strings() {
        
        let result = Result.match(match: "hello", index: any())
        
        let transformer = Transformer<String>()
        
        let rule = Rule.simple { x in "\(x) \(x)" }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual("hello hello", transformed)
    }

    func test_transformSimple_ints() {
        
        let result = Result.match(match: "99", index: any())
        
        let transformer = Transformer<Int>()
        
        let rule = Rule.simple { Int($0).map { $0 + 1 } }
        transformer.append(rule)
        
        let transformed = try! transformer.transform(result)
        XCTAssertEqual(100, transformed)
    }
    
//    func test_transformTagged() {
//        
//        let result = Result.tagged(["int": Result.match(match: "11", index: any())])
//        
//        let transformer = Transformer<Int>()
//        
//        let rule = Rule.tree(["int": Rule.simple()]) {  }
//        transformer.append(rule)
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual(100, transformed)
//    }
}
