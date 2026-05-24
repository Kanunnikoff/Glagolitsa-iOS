//
//  StringExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 29.03.2025.
//

extension String {
    
    var length: Int {
        return self.count
    }
    
    subscript(index: Int) -> Character {
        let requiredIndex = self.index(startIndex, offsetBy: index)
        return self[requiredIndex]
    }
    
    func substring(_ from: Int, _ to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        
        return String(self[startIndex..<endIndex])
    }
//    
//    func substring(from: Int, count: Int) -> String {
//        let startIndex = self.index(self.startIndex, offsetBy: from)
//        let endIndex = self.index(self.startIndex, offsetBy: from + count)
//        let range = startIndex..<endIndex
//        
//        return String(self[range])
//    }
    
    func indexOf(_ substring: String) -> Int {
        guard let range = self.range(of: substring) else {
            return -1
        }
        
        return self.distance(from: self.startIndex, to: range.lowerBound)
    }
    
    func lastIndexOf(_ substring: String) -> Int {
        guard let range = self.range(of: substring, options: .backwards) else {
            return -1
        }
        
        return self.distance(from: self.startIndex, to: range.lowerBound)
    }
    
    func replace(_ str: String, _ replecement: String) -> String {
        return self.replacingOccurrences(of: str, with: replecement)
    }
    
//    func replace(_ regex: Regex<String>, _ replecement: String) -> String {
//        return self.replacing(regex, with: replecement)
//    }
    
    func replace(_ regex: some RegexComponent, _ replecement: String) -> String {
        return self.replacing(regex, with: replecement)
    }
    
//    func replace(_ regex: Regex<Substring>, _ replecement: String) -> String {
//        return self.replacing(regex, with: replecement)
//    }
//    
//    func replace(_ regex: Regex<(Substring, Substring)>, _ replecement: String) -> String {
//        return self.replacing(regex, with: replecement)
//    }
//    
//    func replace(_ regex: Regex<(Substring, Substring, Substring)>, _ replecement: String) -> String {
//        return self.replacing(regex, with: replecement)
//    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func slice(_ start: Int, _ end: Int? = nil) -> String {
        let endIndex: String.Index
        
        if let end = end {
            if end == start {
                return ""
            }
            
            if end < 0 {
                endIndex = self.index(self.endIndex, offsetBy: end)
            } else {
                if end == 0 || end < start {
                    return ""
                }
                
                endIndex = self.index(self.startIndex, offsetBy: end)
            }
        } else {
            endIndex = self.endIndex
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: start)
        
        return String(self[startIndex..<endIndex])
    }
    
    func includes(_ substring: String) -> Bool {
        return self.contains(substring)
    }
    
    func match(_ regex: Regex<Substring>) -> Bool {
        return self.range(of: self, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func charAt(_ index: Int) -> Character {
        return self[index]
    }
    
    func endsWith(_ suffix: String) -> Bool {
        return self.hasSuffix(suffix)
    }
    
    func split(_ separator: String) -> [String] {
        return self.split(separator: separator).map(String.init)
    }
}

// ---

extension String {
    
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    func hasPrefix(_ prefix: String, ignoreCase: Bool) -> Bool {
        return ignoreCase ? lowercased().hasPrefix(prefix.lowercased()) : hasPrefix(prefix)
    }
    
    func contains(_ part: String, ignoreCase: Bool) -> Bool {
        return ignoreCase ? lowercased().contains(part.lowercased()) : contains(part)
    }
    
    func substring(_ from: Int, _ to: Int) -> Substring {
        let index1 = index(startIndex, offsetBy: from)
        let index2 = index(startIndex, offsetBy: to)
        
        return self[index1..<index2]
    }
    
    func substring(_ from: Int) -> Substring {
        let index1 = index(startIndex, offsetBy: from)
        
        return self[index1...]
    }
    
    func get(_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

extension String {
    
    var isCapitalized: Bool {
        get {
            self.first?.isUppercase ?? false
        }
    }
    
    var isAllCapitalized: Bool {
        get {
            self.filter { $0.isLetter }.allSatisfy { $0.isUppercase }
        }
    }
}

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
