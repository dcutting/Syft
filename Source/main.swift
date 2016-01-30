// Arithmetic parser.
let space = " \t\n\r\n".match
let letter = "az".match
let skip = space.some.maybe
let digit = (0...9).match
let op = "+-*/".match.tag("op") >>> skip
let numeral = skip >>> digit.some.tag("numeral") >>> skip
let expression = Deferred()
let compound = numeral.tag("first") >>> op >>> expression.tag("second")
expression.parser = compound | numeral

let input = "  123+  52 \t  \n *  891 \r\n  /3120   "
let parsed = expression.parse(input)
print(parsed)

// Basic regex parser.
let char = (digit | letter).tag("char")
let range = char.tag("start") >>> Parser.Str("-") >>> char.tag("end")
let group = range.tag("range") | char
let groups = group.some.tag("match")

let matchInput = "3-8za-z"
let matchParsed = groups.parse(matchInput)
print(matchParsed)
