//
//  CyrillicTranslatorEditorView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.06.2025.
//

import SwiftUI
import Combine

struct CyrillicTranslatorEditorView: View {
    
    @Binding var textSelection: TextSelection?
    let isFromGlagoliticToCyrillic: Bool
    @StateObject var viewModel: GlagoliticTranslatorViewModel
    let subject: PassthroughSubject<Int, Never>
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Выделение использовать невозможно - ошибка на стороне Apple (номер обращения FB17631120 в Feedback Assistant)
            // Обновление от 29 июня 2025 года: во 2-й beta-версии iOS 26 ошибка исправлена
            TextEditor(text: $viewModel.cyrillicText/*, selection: $textSelection*/)
                .opacity(viewModel.cyrillicText.isEmpty ? 0.7 : 1)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.sentences)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 1)
#elseif os(macOS)
                .padding(10)
#endif
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // TODO: попробовать заменить на иеханизм закругления из iOS 26
                        .stroke(Color(.gray), lineWidth: 1.0)
                )
                .padding(10)
                .onChange(of: viewModel.cyrillicText) { _, value in
                    if !isFromGlagoliticToCyrillic {
                        subject.send(Int.zero)
                    }
                }
            
            Text("Cyrillic")
                .font(.caption)
                .padding(.horizontal, 5)
                .background(Util.systemBackgroundColor)
                .padding(.horizontal, 25)
                .offset(x: 0, y: 3)
        }
    }
}

#Preview {
    CyrillicTranslatorEditorView(
        textSelection: .constant(nil),
        isFromGlagoliticToCyrillic: false,
        viewModel: GlagoliticTranslatorViewModel(),
        subject: PassthroughSubject<Int, Never>()
    )
}
