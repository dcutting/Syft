println("Syft")

let a = Syft.Name("anA", Syft.Str("a"))
let someAs = Syft.Repeat(a, minimum: 0, maximum: 10)

let b = Syft.Name("aB", Syft.Str("b"))
let someBs = Syft.Repeat(b, minimum: 1, maximum: 10)

//let sequence = Syft.Sequence(Syft.Name("thefirstas", someAs), Syft.Sequence(Syft.Name("thebs", someBs), someAs))
let sequence = Syft.Sequence(someAs, someBs)

let result = someAs.parse("aa")

println(result)
