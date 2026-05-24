//
//  GlagoliticToCyrillicTranslator..swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 01.05.2025.
//

struct GlagoliticToCyrillicTranslator: Translator {

    private let converter = Converter.create()

    mutating func prepare() async {
    }

    mutating func translate(
        _ value: String,
        translation: (String) -> Void,
        variantWords: ([VariantWord]) -> Void
    ) {
        // Перенесённый экран ожидает список спорных слов, но обратное глаголическое
        // преобразование однозначно работает через таблицу соответствий.
        translation(converter.convert(fromGlagolitic: value))
        variantWords([])
    }
}
