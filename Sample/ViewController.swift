import Cocoa
import Syft

struct Pipeline<T> {
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
    
    var pipeline = sequenceDiagram()
    
    override func viewWillAppear() {
        super.viewWillAppear()
                
        configureInput()
        updateOutput()
    }
    
    private func configureInput() {
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
    
    func textDidChange(_ obj: Notification) {
        updateOutput()
    }
    
    private func updateOutput() {
        guard let text = input?.string else { return }
        let intermediateSyntaxTree = pipeline.parser.parse(text)
        var abstractSyntaxTreeResult = ""
        var outputResult = "invalid"
        do {
            let abstractSyntaxTree = try pipeline.transformer.transform(intermediateSyntaxTree)
            let resolved = pipeline.resolver(abstractSyntaxTree)
            abstractSyntaxTreeResult = "\(abstractSyntaxTree)"
            outputResult = "\(resolved)"
        } catch {
            abstractSyntaxTreeResult = "\(error)"
        }
        parsed?.string = "\(String(describing: intermediateSyntaxTree))"
        transformed?.string = abstractSyntaxTreeResult
        output?.string = outputResult
    }
}
