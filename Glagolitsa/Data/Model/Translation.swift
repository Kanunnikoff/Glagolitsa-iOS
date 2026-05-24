//
//  Translation.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 09.07.2023.
//

import Foundation
import SwiftData

@Model
class Translation : Identifiable, Hashable {
    var id: UUID
    var createDate: Date
    var originalText: String
    var translatedText: String
    var translationDirection: TranslationDirection
    var rawTranslationDirection: String
    var isFeatured: Bool
    
    init(
        originalText: String,
        translatedText: String,
        translationDirection: TranslationDirection
    ) {
        self.id = UUID()
        self.createDate = Date.now
        self.originalText = originalText
        self.translatedText = translatedText
        self.translationDirection = translationDirection
        self.rawTranslationDirection = translationDirection.rawValue
        self.isFeatured = false
    }
    
    static func stub() -> Translation {
        return Translation(
            originalText: "Дом",
            translatedText: "Ⰴⱁⰿ",
            translationDirection: .glagolitic
        )
    }
}
