import Cocoa
import Syft

class ViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet weak var input: NSTextView!
    @IBOutlet weak var output: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        input.string = "+ 1 2"
        update()
    }
    
    func textDidChange(_ obj: Notification) {
        update()
    }
    
    func update() {
        do {
            guard let text = input.string else { return }
            let result = try parseSequenceDiagram(input: text)
            output.string = "\(result)"
        } catch {
            output.string = "invalid"
        }
    }
}
