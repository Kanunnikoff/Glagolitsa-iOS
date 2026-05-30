//
//  TranslationDetailsView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI

struct TranslationDetailsView: View {
    
    let translation: Translation
    
    var body: some View {
        List {
            let originalSectionHeader = if translation.translationDirection == .glagolitic {
                "Original (Cyrillic)"
            } else {
                "Original (Glagolitic)"
            }
            
            Section {
                VStack(alignment: .leading, spacing: 20) {
                    Text(translation.originalText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CopyButtonView(textToCopy: translation.originalText)
                }
            } header: {
                Text(LocalizedStringKey(originalSectionHeader))
            }
            
            let translationSectionHeader = if translation.translationDirection == .glagolitic {
                "Translation (Glagolitic)"
            } else {
                "Translation (Cyrillic)"
            }
            
            Section {
                VStack(alignment: .leading, spacing: 20) {
                    Text(translation.translatedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CopyButtonView(textToCopy: translation.translatedText)
                }
            } header: {
                Text(LocalizedStringKey(translationSectionHeader))
            }
            
            LabeledContent("Create Date") {
                Text("\(translation.createDate.prettyFormat())")
            }
        }
        .navigationTitle("Translation Details")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    TranslationDetailsView(translation: .stub())
}
