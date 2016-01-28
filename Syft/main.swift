let one = Parser.Str("1")
let two = Parser.Str("2")
let digit = Parser.Either(one, two)
let numeral = Parser.Tag("number", Parser.Repeat(digit, minimum: 1, maximum: nil))
let op = Parser.Either(Parser.Str("+"), Parser.Str("*"))
let expression = DeferredParser(name: "expression")
let compound = Parser.Sequence(Parser.Tag("first", numeral), Parser.Sequence(Parser.Tag("op", op), Parser.Tag("second", Parser.Deferred(expression))))
expression.parser = Parser.Either(numeral, compound)

let repeatedOnes = Parser.Repeat(Parser.Tag("o", one), minimum: 1, maximum: nil)
let someOnes = Parser.Tag("ones", repeatedOnes)
let someTwos = Parser.Repeat(Parser.Tag("t", two), minimum: 1, maximum: nil)
let someOnesAndTwos = Parser.Sequence(someOnes, someTwos)

let input = "111122"//+1*2"
let actualResult = someOnesAndTwos.parse(input)

let expectedResult = Result.Tagged([
    "first": Result.Tagged(["number": Result.Match(match: "12", index: 0)]),
    "op": Result.Match(match: "+", index: 2),
    "second": Result.Tagged([
        "first": Result.Tagged(["number": Result.Match(match: "2", index: 3)]),
        "op": Result.Match(match: "*", index: 4),
        "second": Result.Tagged(["number": Result.Match(match: "1", index: 5)])
    ])
])

//print(expectedResult)
print(actualResult)
