import XCTest
@testable import Syft

class TransformerTests: XCTestCase {
    
    func test_transformValue_returnsValue() {
        let result = Result.match(match: "value", index: 0)
        let resultWithRemainder = (result, Remainder(text: "", index: 0))
        let transformer = Transformer<Int>()
        _ = try! transformer.transform(resultWithRemainder)
    }
}
