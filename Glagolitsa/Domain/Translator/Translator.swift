//
//  Translator.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 01.05.2025.
//

import Foundation

protocol Translator {
    
    mutating func prepare() async
    
    mutating func translate(
        _ value: String,
        translation: (String) -> Void,
        variantWords: ([VariantWord]) -> Void
    )
}
