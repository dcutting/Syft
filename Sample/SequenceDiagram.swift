import Syft

func sequenceDiagram() -> Pipeline<String> {
    return Pipeline(defaultInput: "participant App", parser: makeSequenceDiagramParser(), transformer: makeSequenceDiagramTransformer()) { ast in
        return "\(ast)"
    }
}

func makeSequenceDiagramParser() -> ParserProtocol {
    
    let space = " ".match
    let spaces = space.some
    let skip = spaces.maybe
    let character = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_".match
    let newline = str("\n")

    let token = character.some.tag("token")
    let quotableToken = (character | space).some.tag("token")
    let quote = "\"".match
    let quotedToken = quote >>> quotableToken >>> quote
    let shorthand = spaces >>> str("as") >>> spaces >>> (quotedToken | token).tag("shorthand") >>> skip
    let participantToken = (quotedToken | token).tag("participant")
    let participant = skip >>> str("participant") >>> spaces >>> participantToken >>> (shorthand | spaces).maybe
    
    let source = token.tag("source")
    let destination = token.tag("destination")
    let weakArrow = str("-->")
    let strongArrow = str("->")
    let comment = quotableToken.tag("comment")
    let colon = str(":") >>> skip
    let destinationAndComment = destination >>> colon >>> comment
    let strongEvent = (source >>> strongArrow >>> destinationAndComment).tag("strong")
    let weakEvent = (source >>> weakArrow >>> destinationAndComment).tag("weak")
    let event = strongEvent | weakEvent
    
    let lines = ((event | participant) >>> newline).some.maybe
    
    let parser = lines
    return parser
}

func makeSequenceDiagramTransformer() -> Transformer<String> {
    let transformer = Transformer<String>()
    
    transformer.rule(["token": .simple("t")]) { args in
        try args.raw("t")
    }
    
    transformer.rule(["participant": .simple("p")]) { args in
        "Hello \(try args.transformed("p"))"
    }
    
    return transformer
}
