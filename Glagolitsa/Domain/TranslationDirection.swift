//
//  TranslationDirection.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

enum TranslationDirection: String, Codable, CaseIterable {
    case glagolitic
    case cyrillic
    
    static func fromValue(_ value: String) -> TranslationDirection {
        return TranslationDirection(rawValue: value) ?? .glagolitic
    }
}
