public func makeReport(result: Result, indent: Int = 0) -> String {

    switch result {

    case .failure:
        return "<failure>"

    case let .match(match: match, index: index):
        return makeReport(match: match, index: index)

    case let .tagged(tagged):
        return makeReport(tagged: tagged, indent: indent)

    case let .series(series):
        return makeReport(series: series, indent: indent)

    case let .maybe(maybe):
        return makeReport(maybe: maybe, indent: indent)
    }
}

func makeReport(match: String, index: Int) -> String {
    return "\"\(match)\"@\(index)"
}

func makeReport(tagged: [String: Result], indent: Int) -> String {

    let nextIndent = makeNextIndent(indent: indent)

    let joined = tagged.map { args in
        let valueReport = makeReport(result: args.value, indent: nextIndent)
        return "\(args.key): \(valueReport)".indented(by: nextIndent)
    }.sorted().joined(separator: ",\n")

    return "{\n\(joined)\n" + "}".indented(by: indent)
}

func makeReport(series: [Result], indent: Int) -> String {
    let nextIndent = makeNextIndent(indent: indent)
    let seriesDescription = series.map { element in
        let valueReport = makeReport(result: element, indent: nextIndent)
        return valueReport.indented(by: nextIndent)
    }.joined(separator: "\n")
    return "[\n\(seriesDescription)\n" + "]".indented(by: indent)
}

func makeReport(maybe: Result?, indent: Int) -> String {
    guard let maybe = maybe else { return "" }
    let nextIndent = makeNextIndent(indent: indent)
    let valueReport = makeReport(result: maybe, indent: nextIndent)
    return "\(valueReport)?".indented(by: indent)
}

func makeNextIndent(indent: Int) -> Int {
    let tabIndent = 4
    return indent + tabIndent
}
