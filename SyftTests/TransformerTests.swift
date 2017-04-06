import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
    func test_transformValue_returnsValue() {
        
        let result = Result.match(match: "hello", index: any())

        let transformer = Transformer<String>()
        
        let transformation = Transformation(from: .literal("hello")) { result in
            "world"
        }
        transformer.append(transformation)

        let transformed = try! transformer.transform(result)
        XCTAssertEqual("world", transformed)
    }
}
