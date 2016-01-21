print("Syft")

//let digit = Parser.OneOf(Array(0...9))
//let numeral = Parser.Tag("number", Parser.OneOrMore(digit))
//let op = Parser.Tag("op", Parser.OneOf(["+", "-", "*", "/"]))
//let compound = Parser.AndThen([numeral, op, expression])
//let expression = Parser.OneOf([numeral, compound])

let input = "12+3*4"

//let result = expression.parse(input)

/*

{
    :first => {
        :number => [
            { :d => "1"@0 },
            { :d => "2"@1 }
        ]
    },
    :op => "+"@2,
    :second => {
        :first => {
            :number => [
                { :d => "3"@3 }
            ]
        },
        :op => "*"@4,
        :second => {
            :number => [
                { :d => "4"@5 }
            ]
        }
    }
}

*/

let result = Result.Tagged([
    "first": Result.Tagged([
        "number": Result.Series([
            Result.Tagged(["d": Result.Match(match: "1", index: 0)]),
            Result.Tagged(["d": Result.Match(match: "2", index: 1)])
            ])
        ]),
    "op": Result.Match(match: "+", index: 2),
    "second": Result.Tagged([
        "first": Result.Tagged([
            "number": Result.Series([
                Result.Tagged(["d": Result.Match(match: "3", index: 3)])
                ]),
            "op": Result.Match(match: "*", index: 4),
            "second": Result.Tagged([
                "number": Result.Series([
                    Result.Tagged(["d": Result.Match(match: "4", index: 5)])
                ])
            ])
        ])
    ])
])

print(result)
