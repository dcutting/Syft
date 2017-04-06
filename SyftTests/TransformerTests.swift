import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
    func test_transformLiteral() {
        
        let result = Result.match(match: "hello", index: any())

        let transformer = Transformer<String>()
        
        let rule = Rule(replace: .literal("hello")) { _ in "world" }
        transformer.append(rule)

        let transformed = try! transformer.transform(result)
        XCTAssertEqual("world", transformed)
    }
}
