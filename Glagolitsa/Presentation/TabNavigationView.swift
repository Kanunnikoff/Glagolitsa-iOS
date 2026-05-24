//
//  TabNavigationView.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 19.04.2025.
//

import SwiftUI

struct TabNavigationView: View {

    let glagoliticTranslatorViewModel: GlagoliticTranslatorViewModel
    let chatViewModel: ChatViewModel
    @Binding var isFromGlagoliticToCyrillic: Bool

    @AppStorage("isKeepTranslationHistory")
    private var isKeepTranslationHistory: Bool = true
    
    @AppStorage("isChatTabVisible")
    private var isChatTabVisible: Bool = true
    
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            Tab("Translator", systemImage: "character.bubble") { // 􀌰
                NavigationStack {
                    GlagoliticTranslatorView(
                        viewModel: glagoliticTranslatorViewModel,
                        isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic
                    )
                }
            }
            
            if isChatTabVisible {
                Tab("Chat", systemImage: "ellipsis.message") { // 􁒘
                    NavigationStack {
                        ChatView(viewModel: chatViewModel)
                    }
                }
            }
            
            if isKeepTranslationHistory {
                Tab("History", systemImage: "clock", role: .search) { // 􀐫
                    NavigationStack {
                        HistoryView(searchText: $searchText)
                    }
                }
            }
        }
    }
}

#Preview {
    TabNavigationView(
        glagoliticTranslatorViewModel: GlagoliticTranslatorViewModel(),
        chatViewModel: ChatViewModel(),
        isFromGlagoliticToCyrillic: .constant(false)
    )
}
