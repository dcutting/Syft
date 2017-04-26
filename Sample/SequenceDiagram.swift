import Syft

func parseSequenceDiagram(input: String) -> String {
    let parser = sequenceDiagramParser()
    let result = parser.parse(input)
    return "\(result)"
}

func sequenceDiagramParser() -> ParserProtocol {
    let space = " ".match
    let skip = space.some.maybe
    let character = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_".match
    let quotableToken = (character | space).some
    let quote = "\"".match
    let quotedToken = quote >>> quotableToken.tag("token") >>> quote
    let token = character.some.tag("token")
    let shorthand = skip >>> str("as") >>> skip >>> (quotedToken | token).tag("shorthand")
    let participantToken = quotedToken | token
    let participant = str("participant") >>> skip >>> participantToken.tag("participant") >>> shorthand.maybe
    
    let parser = participant
    return parser
}
