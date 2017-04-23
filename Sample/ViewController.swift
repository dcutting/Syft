import Cocoa
import Syft

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        parse()
    }
    
    func parse() {
        
        // Arithmetic parser.
        let space = " \t\n\r\n".match
        let skip = space.some.maybe
        let digit = (0...9).match
        let op = "+-*/".match.tag("op") >>> skip
        let numeral = skip >>> digit.some.tag("numeral") >>> skip
        let expression = Deferred()
        let compound = numeral.tag("first") >>> op >>> expression.tag("second")
        expression.parser = compound | numeral
        
        let input = "  123+  52 \t  \n *  891 \r\n  /3120   "
        let _ = expression.parse(input)
//        print(parsed)
        
        // Basic regex parser.
        let backslash = str("\\")
        let char = backslash >>> any.tag("char") | any.tag("char")
        let range = char.tag("start") >>> str("-") >>> char.tag("end")
        let group = range.tag("range") | char
        let groups = group.some.tag("groups")
        
        let matchInput = "a-zA-Z0-9_-"
        let _ = groups.parse(matchInput)
//        print(matchParsed)
        
        
        //ist = ["left": ["int": "91"], "op": "+", "right": ["int": "8"]]
        
        let transformable = Transformable<Int>.tree([
            "left": .tree(["int": .leaf(.raw("91"))]),
            "right": .tree(["int": .leaf(.raw("8"))]),
            "op": .leaf(.raw("+"))
            ])
        
        let _ = Transformable<Int>.leaf(.transformed(99))
        
        let intReducer: Reducer<Int> = { captures in
            guard let x = captures["x"] else { return .unexpected }
            switch x {
            case let .leaf(.raw(value)):
                guard let int = Int(value) else { return .unexpected }
                return .success(int)
            default:
                return .unexpected
            }
        }

        let intRule = Rule(pattern: .tree(["int": .capture("x")]), reducer: intReducer)
        
        let opReducer: Reducer<Int> = { captures in
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
        
        let opRule = Rule(pattern: .tree(["left": .capture("x"),
                                          "right": .capture("y"),
                                          "op": .capture("op")
            ]), reducer: opReducer)
        
        let transformer = Transformer<Int>()
        do {
            let result = try transformer.transform(transformable: transformable, rules: [intRule, opRule])
            print(result)
        } catch {
            print(error)
        }
    }
    
//    func transform() {
//        // Arithmetic parser.
//        let space = " \t\n\r\n".match
//        let letter = "az".match
//        let skip = space.some.maybe
//        let digit = (0...9).match
//        //let op = "+-*/".match.tag("op") >>> skip
//        let op = "+".match.tag("op") >>> skip
//        let numeral = skip >>> digit.some.tag("numeral") >>> skip
//        let expression = Deferred()
//        let compound = numeral.tag("first") >>> op >>> expression.tag("second")
//        expression.parser = compound | numeral
//        
//        
//        
//        //let input = "  123+  52 \t  \n *  891 \r\n  /3120   "
//        let input = "123+52"
//        let parsed = expression.parse(input)
//        print(parsed)
//        
    
        //[
        //    first:
        //        [
        //            numeral: "123"
        //        ],
        //    op: "+",
        //    second:
        //        [
        //            numeral: "52"
        //        ]
        //]
        
//        let constantTransformer = Transformation(from: ["numeral": .value("x")]) { (values) -> Expr in
//            var c: Constant!
//            switch values["x"]! {
//            case .value(let v):
//                let int = Int(v)!
//                c = Constant(value: int)
//            default:
//                assertionFailure()
//            }
//            return c
//        }
        
        //[
        //    first: Constant(123),
        //    op: "+",
        //    second: Constant(52)
        //]
        
//        let opTransformer = Transformation(from: ["op": .literal("+"), "first": .transformed("left"), "second": .transformed("right")]) { (values) -> Expr in
//            var left: Constant!
//            var right: Constant!
//            switch values["left"]! {
//            case .transformed(let l):
//                left = l as! Constant
//            default:
//                assertionFailure()
//            }
//            switch values["right"]! {
//            case .transformed(let r):
//                right = r as! Constant
//            default:
//                assertionFailure()
//            }
//            return Plus(first: left, second: right)
//        }
        
//        //Plus(Constant(123), Constant(52))
//        
//        let transformer = Transformer<Expr>()
//        transformer.append(constantTransformer)
//        transformer.append(opTransformer)
//        
//        do {
//            let transformed = try transformer.transform(parsed)
//            let result = transformed.evaluate()
//            
//            print("\(String(describing: result))")
//            // 175
//        } catch {
//            print(error)
//        }
//    }
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
