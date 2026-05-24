//
//  PortraitGlagoliticCentralPaneView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.06.2025.
//

import SwiftUI

struct PortraitGlagoliticCentralPaneView: View {
    
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
            HStack {
                HStack {
                    if isFromGlagoliticToCyrillic {
                        Text(verbatim: "Ⰳ")
                    } else {
                        Text(verbatim: "К")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.callout)
                
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
                
                HStack {
                    if isFromGlagoliticToCyrillic {
                        Text(verbatim: "К")
                    } else {
                        Text(verbatim: "Ⰳ")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.callout)
            }
            
            // MARK: Верхний слой с кнопками
            
            HStack {
                if isTranslationImageButtonVisible {
                    NavigationLink(
                        value: isFromGlagoliticToCyrillic ? viewModel.cyrillicText : viewModel.glagoliticText,
                        label: {
                            Image(systemName: "photo") // 􀏅
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 20)
                                .padding(.leading, 30)
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
                    .padding(.leading, isTranslationImageButtonVisible ? 16 : 30)
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
                        .padding(.trailing, 30)
                }
                .disabled(
                    viewModel.isConverting ||
                    (isFromGlagoliticToCyrillic ? viewModel.cyrillicText.isEmpty : viewModel.glagoliticText.isEmpty)
                )
            }
        }
        .frame(minHeight: 40)
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
    PortraitGlagoliticCentralPaneView(
        isFromGlagoliticToCyrillic: .constant(false),
        viewModel: GlagoliticTranslatorViewModel(),
        isKeepTranslationHistory: false,
        isTranslationImageEnabled: false,
        isCopied: false,
        onSaveTranslation: {},
        onCopy: {}
    )
}
