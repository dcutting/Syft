print("Syft")

let digit = Parser.OneOf(Parser.Str("1"), Parser.Str("2"))
let numeral = Parser.Tag("number", Parser.Repeat(digit, minimum: 1, maximum: nil))
let op = Parser.OneOf(Parser.Str("+"), Parser.Str("*"))
let expression = DeferredParser(name: "expression")
let compound = Parser.Sequence(Parser.Tag("first", numeral), Parser.Sequence(Parser.Tag("op", op), Parser.Tag("second", Parser.Deferred(expression))))
expression.parser = Parser.OneOf(numeral, compound)

let input = "12+1*2"
let actualResult = expression.parse(input)

let expectedResult = Result.Tagged([
    "first": Result.Tagged(["number": Result.Match(match: "12", index: 0)]),
    "op": Result.Match(match: "+", index: 2),
    "second": Result.Tagged([
        "first": Result.Tagged(["number": Result.Match(match: "2", index: 3)]),
        "op": Result.Match(match: "*", index: 4),
        "second": Result.Tagged(["number": Result.Match(match: "1", index: 5)])
    ])
])

print(expectedResult)
print(actualResult)
