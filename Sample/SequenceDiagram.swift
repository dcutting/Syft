import Syft

func parseSequenceDiagram(input: String) throws -> (String, String, String) {
    let parser = sequenceDiagramParser()
    let parsedResult = parser.parse(input)
    let transformedResult = ""
    let outputResult = ""
    return ("\(parsedResult)", "\(transformedResult)", "\(outputResult)")
}

func sequenceDiagramParser() -> ParserProtocol {
    let space = " ".match
    let spaces = space.some
    let skip = space.some.maybe
    let character = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_".match
    let quotableToken = (character | space).some
    let quote = "\"".match
    let quotedToken = quote >>> quotableToken.tag("token") >>> quote
    let token = character.some.tag("token")
    let shorthand = spaces >>> str("as") >>> spaces >>> (quotedToken | token).tag("shorthand")
    let participantToken = quotedToken | token
    let participant = str("participant") >>> spaces >>> participantToken.tag("participant") >>> shorthand.maybe
    
    let parser = participant
    return parser
}
