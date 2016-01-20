print("Syft")

//let digit = Syft.OneOf(Array(0...9))
//let numeral = Syft.Tag("number", Syft.OneOrMore(digit))
//let op = Syft.Tag("op", Syft.OneOf(["+", "-", "*", "/"]))
//let compound = Syft.AndThen([numeral, op, expression])
//let expression = Syft.OneOf([numeral, compound])

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

let result = Result.Hash([
    "first": Result.Hash([
        "number": Result.Array([
            Result.Hash(["d": Result.Match(match: "1", index: 0)]),
            Result.Hash(["d": Result.Match(match: "2", index: 1)])
            ])
        ]),
    "op": Result.Match(match: "+", index: 2),
    "second": Result.Hash([
        "first": Result.Hash([
            "number": Result.Array([
                Result.Hash(["d": Result.Match(match: "3", index: 3)])
                ]),
            "op": Result.Match(match: "*", index: 4),
            "second": Result.Hash([
                "number": Result.Array([
                    Result.Hash(["d": Result.Match(match: "4", index: 5)])
                ])
            ])
        ])
    ])
])

print(result)
