import Cocoa
import Syft

class ViewController: NSViewController, NSTextViewDelegate {
    
    let fontSize: CGFloat = 18.0
    
    @IBOutlet weak var input: NSTextView!
    @IBOutlet weak var parsed: NSTextView!
    @IBOutlet weak var transformed: NSTextView!
    @IBOutlet weak var output: NSTextView!
    
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
        let (parseResult, transformResult, outputResult) = parseArithmetic(input: text)
        parsed?.string = "\(String(describing: parseResult))"
        transformed?.string = transformResult
        output?.string = outputResult
    }
}
