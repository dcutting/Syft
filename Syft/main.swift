let space = " \t\n\r\n".any
let skip = space.some.maybe
let digit = (0...9).any
let op = "+-*/".any.tag("op") >>> skip
let numeral = skip >>> digit.some.tag("numeral") >>> skip
let expression = Deferred()
let compound = numeral.tag("first") >>> op >>> expression.tag("second")
expression.parser = compound | numeral

let input = "  123+  52 \t  \n *  891 \r\n  /3120   "
let parsed = expression.parse(input)
print(parsed)
