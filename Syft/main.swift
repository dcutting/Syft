func makeEither(input: [String]) -> Parser {
    var parser: Parser = Parser.Str(input.head!)
    for s in input.tail {
        parser = Parser.Either(parser, Parser.Str(s))
    }
    return parser
}

let digit = makeEither((0...9).map {"\($0)"})
let numeral = Parser.Tag("number", Parser.Repeat(digit, minimum: 1, maximum: nil))
let op = makeEither(["+","-","*","/"])
let expression = DeferredParser(name: "expression")
let compound = Parser.Sequence(Parser.Tag("first", numeral), Parser.Sequence(Parser.Tag("op", op), Parser.Tag("second", Parser.Deferred(expression))))
expression.parser = Parser.Either(compound, numeral)

let input = "123+52*891/3120"
let parsed = expression.parse(input)

print(parsed)
