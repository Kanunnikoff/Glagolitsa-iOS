//
//  LandscapeGlagoliticTranslatorView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.06.2025.
//

import SwiftUI
import Combine

struct LandscapeGlagoliticTranslatorView: View {
    
    @Binding var isFromGlagoliticToCyrillic: Bool
    @Binding var cyrillicTextSelection: TextSelection?
    @Binding var glagoliticTextSelection: TextSelection?
    let viewModel: GlagoliticTranslatorViewModel
    let isKeepTranslationHistory: Bool
    let isTranslationImageEnabled: Bool
    let isCopied: Bool
    let subject: PassthroughSubject<Int, Never>
    let onSaveTranslation: () -> Void
    let onCopy: () -> Void
    let onHandleVariantWordChoose: (VariantWord, VariantWordChoose) -> Void
    let onSelectVariantWord: (VariantWord?) -> Void
    
    var body: some View {
        HStack {
            if isFromGlagoliticToCyrillic {
                glagoliticEditor
            } else {
                if viewModel.variantWords.isEmpty || !viewModel.isVariantWordsBlockVisible {
                    cyrillicEditor
                } else {
                    VariantWordsView(variantWords: viewModel.variantWords) { variantWord, choose in
                        onHandleVariantWordChoose(variantWord, choose)
                    }
                    .onAppear {
                        onSelectVariantWord(viewModel.variantWords.first)
                    }
                }
            }
            
            LandscapeGlagoliticCentralPaneView(
                isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic,
                viewModel: viewModel,
                isKeepTranslationHistory: isKeepTranslationHistory,
                isTranslationImageEnabled: isTranslationImageEnabled,
                isCopied: isCopied,
                onSaveTranslation: onSaveTranslation,
                onCopy: onCopy
            )
            
            if isFromGlagoliticToCyrillic {
                cyrillicEditor
            } else {
                if viewModel.variantWords.isEmpty || !viewModel.isVariantWordsBlockVisible {
                    glagoliticEditor
                } else {
                    ScrollView {
                        if let variantWord = viewModel.variantWords.first {
                            Text(Util.select(word: variantWord.word, in: viewModel.glagoliticText))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(viewModel.glagoliticText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    var cyrillicEditor: some View {
        CyrillicTranslatorEditorView(
            textSelection: $cyrillicTextSelection,
            isFromGlagoliticToCyrillic: isFromGlagoliticToCyrillic,
            viewModel: viewModel,
            subject: subject
        )
    }
    
    var glagoliticEditor: some View {
        GlagoliticTranslatorEditorView(
            textSelection: $glagoliticTextSelection,
            isFromGlagoliticToCyrillic: isFromGlagoliticToCyrillic,
            viewModel: viewModel,
            subject: subject
        )
    }
}

#Preview {
    LandscapeGlagoliticTranslatorView(
        isFromGlagoliticToCyrillic: .constant(false),
        cyrillicTextSelection: .constant(nil),
        glagoliticTextSelection: .constant(nil),
        viewModel: GlagoliticTranslatorViewModel(),
        isKeepTranslationHistory: false,
        isTranslationImageEnabled: false,
        isCopied: false,
        subject: PassthroughSubject<Int, Never>(),
        onSaveTranslation: {},
        onCopy: {},
        onHandleVariantWordChoose: { _, _ in },
        onSelectVariantWord: { _ in }
    )
}
