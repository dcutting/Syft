import Cocoa
import Syft

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        parse()
    }
    
    func parse() {
        
        arithmeticParser()
        
        // Basic regex parser.
//        let backslash = str("\\")
//        let char = backslash >>> any.tag("char") | any.tag("char")
//        let range = char.tag("start") >>> str("-") >>> char.tag("end")
//        let group = range.tag("range") | char
//        let groups = group.some.tag("groups")
//        
//        let matchInput = "a-zA-Z0-9_-"
//        let _ = groups.parse(matchInput)
//        print(matchParsed)
        
    }
    
    func arithmeticParser() {
        
        // Arithmetic parser.
        let space = " \t\n\r\n".match
        let skip = space.some.maybe
        let digit = (0...9).match
        let op = "+-*/".match.tag("op") >>> skip
        let numeral = skip >>> digit.some.tag("numeral") >>> skip
        let expression = Deferred()
        let compound = numeral.tag("first") >>> op >>> expression.tag("second")
        expression.parser = compound | numeral
        
        let input = "  123+  52 \t  \n +  891 \r\n  +3120   "
        let parsed = expression.parse(input)
        
        let intReducer: TransformerReducer<Int> = { captures in
            guard let x = captures["x"] else { return .unexpected }
            switch x {
            case let .leaf(.raw(value)):
                guard let int = Int(value) else { return .unexpected }
                return .success(int)
            default:
                return .unexpected
            }
        }

        let intRule = TransformerRule(pattern: .tree(["numeral": .capture("x")]), reducer: intReducer)
        
        let opReducer: TransformerReducer<Int> = { captures in
            guard let x = captures["x"] else { return .unexpected }
            guard let y = captures["y"] else { return .unexpected }
            guard let op = captures["op"] else { return .unexpected }
            guard case .leaf(.raw("+")) = op else { return .noMatch }
            switch (x, y) {
            case let (.leaf(.transformed(left)), .leaf(.transformed(right))):
                return .success(Int(left + right))
            default:
                return .unexpected
            }
        }
        
        let opRule = TransformerRule(pattern: .tree(["first": .capture("x"),
                                          "second": .capture("y"),
                                          "op": .capture("op")
            ]), reducer: opReducer)
        
        let transformer = Transformer<Int>()
        let ist = parsed.0
        print(ist)
        do {
            let result = try transformer.transform(ist: ist, rules: [intRule, opRule])
            print(result)
        } catch {
            print(error)
        }
    }
}

protocol Expr {
    func evaluate() -> Int
}

struct Constant: Expr {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func evaluate() -> Int {
        return value
    }
}

struct Plus: Expr {
    let first: Expr
    let second: Expr
    
    func evaluate() -> Int {
        return first.evaluate() + second.evaluate()
    }
}
