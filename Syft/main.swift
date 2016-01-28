let digit = (0...9).any
let op = "+-*/".any
let numeral = digit.some.tag("numeral")
let expression = Deferred()
let compound = numeral.tag("first") >>> op.tag("op") >>> expression.tag("second")
expression.parser = compound | numeral

let input = "123+52*891/3120"
let parsed = expression.parse(input)

print(parsed)
