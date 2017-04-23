import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
//    func test_transformLiteral_strings() {
//        
//        let result = Result.match(match: "hello", index: any())
//        
//        let transformer = Transformer<String>()
//        
//        let rule = Rule.literal("hello") { "world" }
//        transformer.append(rule)
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual("world", transformed)
//    }
//    
//    func test_transformLiteral_ints() {
//        
//        let result = Result.match(match: "99", index: any())
//        
//        let transformer = Transformer<Int>()
//        
//        let rule = Rule.literal("99") { 100 }
//        transformer.append(rule)
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual(100, transformed)
//    }
    
//    func test_transformSimple_strings() {
//        
//        let result = Result.match(match: "hello", index: any())
//        
//        let transformer = Transformer<String>()
//        
//        let rule = Rule(pattern: .simple("x")) { args in
//            let x = args["x"]!
//            return "\(x) \(x)"
//        }
//        transformer.append(rule)
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual("hello hello", transformed)
//    }
//
//    func test_transformSimple_ints() {
//        
//        let result = Result.match(match: "99", index: any())
//        
//        let rule = TransformerRule<Int>(pattern: .simple("x")) { args in
//            guard let xa = args["x"] else { return nil }
//            guard let x = Int(xa) else { return nil }
//            return x + 1
//        }
//
//        let transformer = Transformer<Int>(rules: [rule])
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual(100, transformed)
//    }
//    
//    func test_transformTagged() {
//        
//        let result = Result.tagged(["int": Result.match(match: "91", index: any())])
//        
//        let transformer = Transformer<Int>()
//        
//        let rule = Rule<Int>(pattern: .tree(["int": .simple("x")])) { args in
//            guard let xa = args["x"] else { return nil }
//            guard let x = Int(xa) else { return nil }
//            return x + 1
//        }
//        transformer.append(rule)
//        
//        let transformed = try! transformer.transform(result)
//        XCTAssertEqual(92, transformed)
//    }
}
