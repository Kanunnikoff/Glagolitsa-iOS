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
        "ґ": "ⰳ",
        "д": "ⰴ",
        "е": "ⰵ",
        "є": "ⰵ",
        "ё": "ⱖ",
        "ж": "ⰶ",
        "ѕ": "ⰷ",
        "з": "ⰸ",
        "и": "ⰻ",
        "і": "ⰹ",
        "ї": "ⰹ",
        "й": "ⰺ",
        "ꙉ": "ⰼ",
        "ћ": "ⰼ",
        "ђ": "ⰼ",
        "к": "ⰽ",
        "л": "ⰾ",
        "љ": "ⰾ",
        "м": "ⰿ",
        "н": "ⱀ",
        "њ": "ⱀ",
        "о": "ⱁ",
        "п": "ⱂ",
        "р": "ⱃ",
        "с": "ⱄ",
        "т": "ⱅ",
        "у": "ⱆ",
        "ф": "ⱇ",
        "х": "ⱈ",
        "ѡ": "ⱉ",
        "ц": "ⱌ",
        "ч": "ⱍ",
        "џ": "ⱍ",
        "ш": "ⱎ",
        "щ": "ⱋ",
        "ъ": "ⱏ",
        "ы": "ⱏⰺ",
        "ь": "ⱐ",
        "ѣ": "ⱑ",
        "э": "ⰵ",
        "ю": "ⱓ",
        "я": "ⱔ",
        "ѧ": "ⱔ",
        "ѩ": "ⱗ",
        "ѫ": "ⱘ",
        "ѭ": "ⱙ",
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
        var result = text.replacingOccurrences(of: "ⱏⰺ", with: "ы")
            .replacingOccurrences(of: "ⰵ", with: "е")
            .replacingOccurrences(of: "ⱔ", with: "я")
            .replacingOccurrences(of: "ⰳ", with: "г")
            .replacingOccurrences(of: "ⰹ", with: "і")
            .replacingOccurrences(of: "ⰼ", with: "ꙉ")
            .replacingOccurrences(of: "ⰾ", with: "л")
            .replacingOccurrences(of: "ⱀ", with: "н")
            .replacingOccurrences(of: "ⱍ", with: "ч")
        
            .replacingOccurrences(of: "ⰟⰊ", with: "Ы")
            .replacingOccurrences(of: "Ⰵ", with: "Е")
            .replacingOccurrences(of: "Ⱔ", with: "Я")
            .replacingOccurrences(of: "Ⰳ", with: "Г")
            .replacingOccurrences(of: "Ⰹ", with: "І")
            .replacingOccurrences(of: "Ⰼ", with: "Ꙉ")
            .replacingOccurrences(of: "Ⰾ", with: "Л")
            .replacingOccurrences(of: "Ⱀ", with: "Н")
            .replacingOccurrences(of: "Ⱍ", with: "Ч")
        
        for (cyrillicLetter, glagoliticLetter) in lettersMapping {
            result = result.replacingOccurrences(of: glagoliticLetter, with: cyrillicLetter)
            result = result.replacingOccurrences(of: glagoliticLetter.uppercased(), with: cyrillicLetter.uppercased())
        }
        
        return result
    }
}
