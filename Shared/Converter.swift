//
//  Converter.swift
//  Converter
//
//  Created by Kanunnikov Dmitriy Sergeevich on 02.09.2021.
//

class Converter {
    
    private let lettersMapping = [
        "а": "ⰰ",
        "б": "ⰱ",
        "в": "ⰲ",
        "г": "ⰳ",
        "д": "ⰴ",
        "е": "ⰵ",
        "ё": "ⱘ",
        "ж": "ⰶ",
        "з": "ⰸ",
        "и": "ⰻ",
        "і": "ⰺ",
        "й": "ⰹ",
        "к": "ⰽ",
        "л": "ⰾ",
        "м": "ⰿ",
        "н": "ⱀ",
        "о": "ⱁ",
        "п": "ⱂ",
        "р": "ⱃ",
        "с": "ⱄ",
        "т": "ⱅ",
        "у": "ⱆ",
        "ф": "ⱇ",
        "х": "ⱈ",
        "ц": "ⱌ",
        "ч": "ⱍ",
        "ш": "ⱎ",
        "щ": "ⱋ",
        "ъ": "ⱏ",
        "ы": "ⱏⰺ",
        "ь": "ⱐ",
        "ѣ": "ⱑ",
        "э": "ⰵ",
        "ю": "ⱓ",
        "я": "ⱔ",
        "ѳ": "ⱚ",
        "ѵ": "ⱛ"
    ]
    
    private static var instance: Converter? = nil
    
    private init() {
    }
    
    static func create() -> Converter {
        if instance == nil {
            instance = Converter()
        }
        
        return instance!
    }
    
    func convert(fromCyrillic text: String) async -> String {
        var result = text
        
        for (cyrillicLetter, glagoliticLetter) in lettersMapping {
            result = result.replacingOccurrences(of: cyrillicLetter, with: glagoliticLetter)
            result = result.replacingOccurrences(of: cyrillicLetter.uppercased(), with: glagoliticLetter.uppercased())
        }
        
        return result
    }
    
    func convert(fromGlagolitic text: String) async -> String {
        var result = text.replacingOccurrences(of: "ⱏⰺ", with: "ы").replacingOccurrences(of: "ⰵ", with: "е")
        
        for (cyrillicLetter, glagoliticLetter) in lettersMapping {
            result = result.replacingOccurrences(of: glagoliticLetter, with: cyrillicLetter)
            result = result.replacingOccurrences(of: glagoliticLetter.uppercased(), with: cyrillicLetter.uppercased())
//            print("\(cyrillicLetter) -> lowercased: \(glagoliticLetter.lowercased()), uppercased: \(glagoliticLetter.uppercased())")
        }
        
        return result
    }
}
