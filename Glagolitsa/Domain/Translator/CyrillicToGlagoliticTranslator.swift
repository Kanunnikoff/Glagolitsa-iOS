//
//  Converter.swift
//  Converter
//
//  Created by Kanunnikov Dmitriy Sergeevich on 02.09.2021.
//

import Foundation

enum GlagoliticILetter: String, CaseIterable, Identifiable {

    static let storageKey = "glagoliticILetter"
    static let defaultValue: GlagoliticILetter = .i

    case i
    case izhe
    case initialIzhe

    var id: String {
        rawValue
    }

    var glagoliticLetter: String {
        switch self {
            case .i: "ⰻ"
            case .izhe: "ⰹ"
            case .initialIzhe: "ⰺ"
        }
    }

    var settingsTitle: String {
        switch self {
            case .i: "ⰻ I"
            case .izhe: "ⰹ Izhe"
            case .initialIzhe: "ⰺ Initial Izhe"
        }
    }

    static func current(userDefaults: UserDefaults = .standard) -> GlagoliticILetter {
        guard let rawValue = userDefaults.string(forKey: storageKey) else {
            return defaultValue
        }

        return GlagoliticILetter(rawValue: rawValue) ?? defaultValue
    }
}

final class Converter {

    private typealias LetterMapping = (cyrillicLetter: String, glagoliticLetter: String)

    private static let cyrillicILetter = "и"
    private static let cyrillicYeryLetter = "ы"
    private static let glagoliticYeryLetter = "ⱏⰺ"

    // Порядок важен для обратного перевода: первым вариантом для общего
    // глаголического знака становится современная русская буква.
    private static let lettersMapping: [LetterMapping] = [
        ("а", "ⰰ"),
        ("б", "ⰱ"),
        ("в", "ⰲ"),
        ("г", "ⰳ"),
        ("ґ", "ⰳ"),
        ("д", "ⰴ"),
        ("е", "ⰵ"),
        ("є", "ⰵ"),
        ("ё", "ⱖ"),
        ("ж", "ⰶ"),
        ("ѕ", "ⰷ"),
        ("з", "ⰸ"),
        ("і", "ⰹ"),
        ("ї", "ⰹ"),
        ("й", "ⰺ"),
        ("ꙉ", "ⰼ"),
        ("ћ", "ⰼ"),
        ("ђ", "ⰼ"),
        ("к", "ⰽ"),
        ("л", "ⰾ"),
        ("љ", "ⰾ"),
        ("м", "ⰿ"),
        ("н", "ⱀ"),
        ("њ", "ⱀ"),
        ("о", "ⱁ"),
        ("п", "ⱂ"),
        ("р", "ⱃ"),
        ("с", "ⱄ"),
        ("т", "ⱅ"),
        ("у", "ⱆ"),
        ("ф", "ⱇ"),
        ("х", "ⱈ"),
        ("ѡ", "ⱉ"),
        ("ц", "ⱌ"),
        ("ч", "ⱍ"),
        ("џ", "ⱍ"),
        ("ш", "ⱎ"),
        ("щ", "ⱋ"),
        ("ъ", "ⱏ"),
        (cyrillicYeryLetter, glagoliticYeryLetter),
        ("ь", "ⱐ"),
        ("ѣ", "ⱑ"),
        ("э", "ⰵ"),
        ("ю", "ⱓ"),
        ("я", "ⱔ"),
        ("ѧ", "ⱔ"),
        ("ѩ", "ⱗ"),
        ("ѫ", "ⱘ"),
        ("ѭ", "ⱙ"),
        ("ѳ", "ⱚ"),
        ("ѵ", "ⱛ")
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

    func convert(
        fromCyrillic text: String,
        glagoliticILetter: GlagoliticILetter = .current()
    ) -> String {
        var result = text

        replace(
            sourceLetter: Self.cyrillicILetter,
            targetLetter: glagoliticILetter.glagoliticLetter,
            in: &result
        )

        for (cyrillicLetter, glagoliticLetter) in Self.lettersMapping {
            replace(sourceLetter: cyrillicLetter, targetLetter: glagoliticLetter, in: &result)
        }

        return result
    }

    func convert(
        fromGlagolitic text: String,
        glagoliticILetter: GlagoliticILetter = .current()
    ) -> String {
        var result = text

        // Составная ы содержит ⰺ, поэтому должна заменяться до обработки
        // выбранной пользователем буквы и.
        replace(
            sourceLetter: Self.glagoliticYeryLetter,
            targetLetter: Self.cyrillicYeryLetter,
            in: &result
        )

        replace(
            sourceLetter: glagoliticILetter.glagoliticLetter,
            targetLetter: Self.cyrillicILetter,
            in: &result
        )

        for (cyrillicLetter, glagoliticLetter) in Self.lettersMapping {
            replace(sourceLetter: glagoliticLetter, targetLetter: cyrillicLetter, in: &result)
        }

        return result
    }

    private func replace(sourceLetter: String, targetLetter: String, in text: inout String) {
        text = text.replacingOccurrences(of: sourceLetter, with: targetLetter)
        text = text.replacingOccurrences(of: sourceLetter.uppercased(), with: targetLetter.uppercased())
    }
    
//    @available(iOS 15.0, macOS 12.0, *)
//    func convertAsync(fromCyrillic text: String) async -> String {
//        return convert(fromCyrillic: text)
//    }
//    
//    @available(iOS 15.0, macOS 12.0, *)
//    func convertAsync(fromGlagolitic text: String) async -> String {
//        return convert(fromGlagolitic: text)
//    }
}

struct CyrillicToGlagoliticTranslator: Translator {

    private let converter = Converter.create()

    mutating func prepare() async {
    }

    mutating func translate(
        _ value: String,
        translation: (String) -> Void,
        variantWords: ([VariantWord]) -> Void
    ) {
        // Перенесённый экран ожидает список спорных слов, но у глаголического
        // преобразования нет словарной постобработки и ручного выбора.
        translation(converter.convert(fromCyrillic: value))
        variantWords([])
    }
}
