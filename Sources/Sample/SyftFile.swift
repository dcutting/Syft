import Syft

func syftFile() -> Pipeline<ParserProtocol> {
    return Pipeline(defaultInput: "comma=\"hi\";\ngrammar=comma;\n", parser: makeSyftFileParser(), transformer: makeSyftFileTransformer()) { ast in
        let result = str("ok") | str("nok")
        return "\(result)"
    }
}

func makeSyftFileParser() -> ParserProtocol {

    let space = " \t".match
    let skip = space.recur
    let newline = str("\n")
    let letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".match
    let digit = "0123456789".match
    let symbol = "[]{}()<>=|.,;".match
    let character = letter | digit | symbol | str("_")
    let identifier = (letter >>> (letter | digit | str("_")).recur).tag("identifier")
    let singleQuotedTerminal = str("'") >>> (character | str("\"")).recur.tag("terminal") >>> str("'")
    let doubleQuotedTerminal = str("\"") >>> (character | str("'")).recur.tag("terminal") >>> str("\"")
    let terminal = singleQuotedTerminal | doubleQuotedTerminal
    let lhs = identifier
    let rhs = Deferred()
    let atom = (identifier | terminal).tag("atom") >>> skip
    let and = Deferred()
    and.parser = (atom.tag("first") >>> (str(",") >>> and.tag("second")).recur).tag("and")
    let or = Deferred()
    or.parser = (and.tag("first") >>> (str("|") >>> or.tag("second")).recur).tag("or")
    rhs.parser = or
        | str("[") >>> rhs.tag("optional") >>> str("]")
        | str("{") >>> rhs.tag("repetition") >>> str("}")
        | str("(") >>> rhs.tag("grouping") >>> str(")")
    let rule = lhs.tag("lhs") >>> str("=") >>> rhs.tag("rhs") >>> str(";") >>> newline.recur
    let grammar = rule.tag("rule").recur
    return grammar
}

enum SyftFileError: Error {
    case invalid
}

class IntermediateParser {
    
    var symbols: [String: Deferred] = [:]
    
    func evaluate() -> ParserProtocol {
//        for symbol, rule in symbols {
//            
//        }
        return str("nok")
    }
}

func makeSyftFileTransformer() -> Transformer<ParserProtocol> {
    
    let transformer = Transformer<ParserProtocol>()
    
    transformer.rule(["terminal": .simple("x")]) { args in
        let terminal = try args.str("x")
        return str(terminal)
    }
    transformer.rule(["identifier": .simple("x")]) { args in
        let terminal = try args.str("x")
        return str(terminal)
    }
//    transformer.rule(["lhs": .simple("symbol"), "rhs": .simple("rule")]) { args in
//        let symbol = try args.raw("symbol")
//        let rule = try args.raw("rule")
//        
//        return
//    }
    
    return transformer
}
