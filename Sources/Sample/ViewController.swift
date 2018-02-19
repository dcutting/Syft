import Cocoa
import Syft

struct Pipeline<T> {
    let defaultInput: String
    let parser: ParserProtocol
    let transformer: Transformer<T>
    let resolver: (T) -> String
}

class ViewController: NSViewController, NSTextViewDelegate {
    
    let fontSize: CGFloat = 18.0
    
    @IBOutlet weak var input: NSTextView!
    @IBOutlet weak var parsed: NSTextView!
    @IBOutlet weak var transformed: NSTextView!
    @IBOutlet weak var output: NSTextView!
    
    var pipeline = iota()
    
    override func viewWillAppear() {
        super.viewWillAppear()
                
        configure()
        updateDefaultInput()
        updateOutput()
    }
    
    private func configure() {
        input?.isAutomaticQuoteSubstitutionEnabled = false
        input?.isAutomaticDataDetectionEnabled = false
        input?.isAutomaticLinkDetectionEnabled = false
        input?.isAutomaticTextReplacementEnabled = false
        input?.isAutomaticDashSubstitutionEnabled = false
        input?.isAutomaticSpellingCorrectionEnabled = false
        
        input?.font = NSFont.systemFont(ofSize: fontSize)
        parsed?.font = NSFont.systemFont(ofSize: fontSize)
        transformed?.font = NSFont.systemFont(ofSize: fontSize)
        output?.font = NSFont.systemFont(ofSize: fontSize)
    }
    
    private func updateDefaultInput() {
        input?.string = pipeline.defaultInput
    }
    
    func textDidChange(_ obj: Notification) {
        updateOutput()
    }
    
    private func updateOutput() {
        guard let text = input?.string else { return }
        let parserResult = pipeline.parser.parse(text)
        let (ist, remainder) = parserResult
        var abstractSyntaxTreeResult = ""
        var outputResult = ""
        do {
            let abstractSyntaxTree = try pipeline.transformer.transform(parserResult)
            let resolved = pipeline.resolver(abstractSyntaxTree)
            abstractSyntaxTreeResult = "\(abstractSyntaxTree)"
            outputResult = "\(resolved)"
        } catch {
            abstractSyntaxTreeResult = "\(error)"
        }
        let report = makeReport(result: ist)
        parsed?.string = "\(remainder)\n\n\(report)"
        transformed?.string = abstractSyntaxTreeResult
        output?.string = outputResult
    }
}
