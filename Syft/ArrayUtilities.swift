extension Array {
    
    var head : T? {
        return self.first
    }
    
    var tail : Array<T> {
        return count < 1 ? self : Array(self[1..<count])
    }
}

extension Array {
    
    func sortedDescription() -> String {
        
        let joined = ", ".join(self.map { "\($0)" }.sorted { $0 < $1 })
        
        return "[\(joined)]"
    }
}
