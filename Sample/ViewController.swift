import Cocoa
import Syft

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseExamples()
    }
    
    func parseExamples() {
        arithmeticParser()
        //regexParser()
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
        
        let intReducer: TransformerReducer<Expr> = { captures in
            guard let x = captures["x"] else { return .unexpected }
            switch x {
            case let .leaf(.raw(value)):
                guard let int = Int(value) else { return .unexpected }
                let constant = Constant(value: int)
                return .success(constant)
            default:
                return .unexpected
            }
        }
        
        let intRule = TransformerRule(pattern: .tree(["numeral": .capture("x")]), reducer: intReducer)
        
        let opReducer: TransformerReducer<Expr> = { captures in
            guard let x = captures["x"] else { return .unexpected }
            guard let y = captures["y"] else { return .unexpected }
            guard let op = captures["op"] else { return .unexpected }
            guard case .leaf(.raw("+")) = op else { return .noMatch }
            switch (x, y) {
            case let (.leaf(.transformed(left)), .leaf(.transformed(right))):
                let plus = Plus(first: left, second: right)
                return .success(plus)
            default:
                return .unexpected
            }
        }
        
        let opRule = TransformerRule(pattern: .tree(["first": .capture("x"),
                                                     "second": .capture("y"),
                                                     "op": .capture("op")
            ]), reducer: opReducer)
        let transformer = Transformer(rules: [intRule, opRule])

        // Parse and transform input.
        do {
            let input = "  123+  52 \t  \n +  891 \r\n  +3120   "
            let ist = expression.parse(input)
            let ast = try transformer.transform(ist)
            let result = ast.evaluate()
            print("\(input) = \(result)")
        } catch {
            print(error)
        }
    }
    
    func regexParser() {
        let backslash = str("\\")
        let char = backslash >>> any.tag("char") | any.tag("char")
        let range = char.tag("start") >>> str("-") >>> char.tag("end")
        let group = range.tag("range") | char
        let groups = group.some.tag("groups")
        
        let matchInput = "a-zA-Z0-9_-"
        let parsed = groups.parse(matchInput)
        print(parsed)
    }
}

protocol Expr {
    func evaluate() -> Int
}

struct Constant: Expr {
    let value: Int
    
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
