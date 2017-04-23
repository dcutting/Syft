import Cocoa
import Syft

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseExamples()
    }
    
    func parseExamples() {
        runArithmetic()
        //runRegex()
    }
        
    func runRegex() {
        let backslash = str("\\")
        let char = backslash >>> any.tag("char") | any.tag("char")
        let range = char.tag("start") >>> str("-") >>> char.tag("end")
        let group = range.tag("range") | char
        let groups = group.some.tag("groups")
        
        let matchInput = "a-zA-Z0-9_-"
        let parsed = groups.parse(matchInput)
        print(parsed)
    }
}
