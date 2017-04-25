import Cocoa
import Syft

class ViewController: NSViewController {
    
    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.stringValue = "+ 1 2"
        update()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        update()
    }
    
    func update() {
        do {
            let text = inputTextField.stringValue
            let result = try calculate(polishNotationInput: text)
            outputLabel.stringValue = "\(result)"
        } catch {
            outputLabel.stringValue = "invalid"
        }
    }
}
