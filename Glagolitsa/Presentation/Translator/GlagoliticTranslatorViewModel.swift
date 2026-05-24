//
//  GlagoliticTranslatorViewModel.swift
//  GlagoliticTranslatorViewModel
//
//  Created by Kanunnikov Dmitriy Sergeevich on 22.03.2025.
//

import Foundation

@MainActor
@Observable
final class GlagoliticTranslatorViewModel: ObservableObject {
    
    private var cyrillicToGlagoliticTranslator: Translator = CyrillicToGlagoliticTranslator()
    private var glagoliticToCyrillicTranslator: Translator = GlagoliticToCyrillicTranslator()
    
    var cyrillicText: String = ""
    var glagoliticText: String = ""
    
    var variantWords: [VariantWord] = []
    var isVariantWordsBlockVisible: Bool = false
    
    var isConverting: Bool = false
    var isTranslationSaved: Bool = false
    
    init() {
        Task {
            await cyrillicToGlagoliticTranslator.prepare()
            await glagoliticToCyrillicTranslator.prepare()
        }
    }
    
    func convertFromCyrillicToGlagolitic() async {
        let sourceText = cyrillicText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !sourceText.isEmpty else {
            return
        }
        
        isConverting = true

        cyrillicToGlagoliticTranslator.translate(
            cyrillicText,
            translation: { translation in
                glagoliticText = translation
                isTranslationSaved = false
            },
            variantWords: { variantWords in
                self.variantWords = variantWords
            }
        )

        isConverting = false
    }
    
    func convertFromGlagoliticToCyrillic() async {
        let sourceText = glagoliticText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !sourceText.isEmpty else {
            return
        }
        
        isConverting = true

        glagoliticToCyrillicTranslator.translate(
            glagoliticText,
            translation: { translation in
                cyrillicText = translation
                isTranslationSaved = false
            },
            variantWords: { variantWords in
                self.variantWords = variantWords
            }
        )

        isConverting = false
    }
    
    func clear() {
        cyrillicText = ""
        glagoliticText = ""
        
        variantWords.removeAll()
        isVariantWordsBlockVisible = false
        
        isTranslationSaved = false
    }
}
