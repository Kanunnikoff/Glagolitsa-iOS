//
//  ToolbarMenuView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 18.03.2025.
//

import SwiftUI

struct ToolbarMenuView: View {
    
    let menuButtonTip: MenuButtonTip
    
    @AppStorage("translationDirection")
    private var translationDirection: TranslationDirection = .glagolitic
    
    var body: some View {
        Menu {
            Picker(selection: $translationDirection) {
                ForEach(TranslationDirection.allCases, id: \.self) { direction in
                    Text(LocalizedStringKey(String(describing: direction)))
                        .tag(direction)
                }
            } label: {
                Label("Translation Direction", systemImage: "books.vertical") // 􀬒
            }
            .pickerStyle(.menu)
        } label: {
            Image(systemName: "ellipsis.circle") // 􀍡
        }
        .onTapGesture {
            menuButtonTip.invalidate(reason: .actionPerformed)
        }
    }
}

#Preview {
    ToolbarMenuView(
        menuButtonTip: .init()
    )
}
