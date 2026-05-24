//
//  ArrayExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 3/30/25.
//

extension Array {
    
    var length: Int {
        return count
    }
    
    func indexOf(_ element: Element) -> Int where Element: Equatable {
        if let index = self.firstIndex(of: element) {
            return index
        }
        
        return -1
    }
    
    func findIndex(_ predicate: (Element) throws -> Bool) rethrows -> Int {
        for (index, element) in self.enumerated() {
            if try predicate(element) {
                return index
            }
        }
        
        return -1
    }
    
    func slice(_ start: Int, _ end: Int? = nil) -> Array {
        if let end = end {
            if end == start {
                return []
            }
            
            return Array(self[start..<end])
        }
        
        return Array(self[start...])
    }
    
    func join(_ separator: String = "") -> String {
        return self.reduce("", { (result, element) -> String in
            result + separator + String(describing: element)
        })
    }
}
