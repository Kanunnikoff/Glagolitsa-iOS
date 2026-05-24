//
//  LandscapeGlagoliticCentralPaneView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.06.2025.
//

import SwiftUI

struct LandscapeGlagoliticCentralPaneView: View {
    
    @Binding var isFromGlagoliticToCyrillic: Bool
    let viewModel: GlagoliticTranslatorViewModel
    let isKeepTranslationHistory: Bool
    let isTranslationImageEnabled: Bool
    let isCopied: Bool
    let onSaveTranslation: () -> Void
    let onCopy: () -> Void
    
    var body: some View {
        ZStack {
            // MARK: Нижний слой с центральной кнопкой смены направления перевода
            VStack {
                if isFromGlagoliticToCyrillic {
                    Text(verbatim: "Ⰳ")
                } else {
                    Text(verbatim: "К")
                }
                
                if viewModel.isConverting {
                    ProgressView()
                        .frame(width: 20, height: 20)
                } else {
                    Button {
                        withAnimation {
                            isFromGlagoliticToCyrillic.toggle()
                        }
                    } label: {
                        Image(systemName: "arrow.left.arrow.right") // 􀄭
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                
                if isFromGlagoliticToCyrillic {
                    Text(verbatim: "К")
                } else {
                    Text(verbatim: "Ⰳ")
                }
            }
            .font(.callout)
            
            // MARK: Верхний слой с кнопками
            
            VStack {
                if isTranslationImageButtonVisible {
                    NavigationLink(
                        value: isFromGlagoliticToCyrillic ? viewModel.cyrillicText : viewModel.glagoliticText,
                        label: {
                            Image(systemName: "photo") // 􀏅
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 20)
                                .padding(.top, 30)
                        }
                    )
                    .disabled(
                        (isFromGlagoliticToCyrillic ? viewModel.cyrillicText.isEmpty : viewModel.glagoliticText.isEmpty) ||
                        viewModel.isConverting
                    )
                }
                
                if isKeepTranslationHistory {
                    Button {
                        onSaveTranslation()
                    } label: {
                        Image(systemName: "square.and.arrow.down.badge.clock") // 􂰵
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 23)
                    }
                    .padding(.top, isTranslationImageButtonVisible ? 16 : 30)
                    .disabled(
                        (isFromGlagoliticToCyrillic ? viewModel.cyrillicText.isEmpty : viewModel.glagoliticText.isEmpty) ||
                        viewModel.isTranslationSaved || viewModel.isConverting
                    )
                }
                
                Spacer()
                
                Button {
                    onCopy()
                } label: {
                    Image(systemName: isCopied ? "checkmark": "square.on.square") // 􀆅 : 􀐅
                        .resizable()
                        .scaledToFit()
                        .contentTransition(.symbolEffect(.replace))
                        .frame(maxHeight: 20)
                        .padding(.bottom, 30)
                }
                .disabled(
                    viewModel.isConverting ||
                    (isFromGlagoliticToCyrillic ? viewModel.cyrillicText.isEmpty : viewModel.glagoliticText.isEmpty)
                )
            }
        }
        .frame(minWidth: 40)
#if os(macOS)
        .buttonStyle(.plain)
#endif
    }

    private var isTranslationImageButtonVisible: Bool {
#if os(macOS)
        false
#else
        isTranslationImageEnabled
#endif
    }
}

#Preview {
    LandscapeGlagoliticCentralPaneView(
        isFromGlagoliticToCyrillic: .constant(false),
        viewModel: GlagoliticTranslatorViewModel(),
        isKeepTranslationHistory: false,
        isTranslationImageEnabled: false,
        isCopied: false,
        onSaveTranslation: {},
        onCopy: {}
    )
}
