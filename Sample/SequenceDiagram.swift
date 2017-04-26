import Syft

func sequenceDiagram() -> Pipeline<String> {
    return Pipeline(parser: makeSequenceDiagramParser(), transformer: makeSequenceDiagramTransformer()) { ast in
        return "\(ast)"
    }
}

func makeSequenceDiagramParser() -> ParserProtocol {
    let space = " ".match
    let spaces = space.some
    let skip = spaces.maybe
    let character = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_".match
    let token = character.some.tag("token")
    let quotableToken = (character | space).some.tag("token")
    let quote = "\"".match
    let quotedToken = quote >>> quotableToken >>> quote
    let shorthand = spaces >>> str("as") >>> spaces >>> (quotedToken | token).tag("shorthand") >>> skip
    let participantToken = (quotedToken | token).tag("participant")
    let participant = skip >>> str("participant") >>> spaces >>> participantToken >>> (shorthand | spaces).maybe
    
    let parser = participant
    return parser
}

func makeSequenceDiagramTransformer() -> Transformer<String> {
    return Transformer<String>()
}
