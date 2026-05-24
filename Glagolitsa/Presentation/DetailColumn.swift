//
//  DetailColumn.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 03.07.2023.
//

import SwiftUI

struct DetailColumn: View {
    
    @Binding var selection: SidebarItem?
    let glagoliticTranslatorViewModel: GlagoliticTranslatorViewModel
    let chatViewModel: ChatViewModel
    @Binding var isFromGlagoliticToCyrillic: Bool
    
    @State private var searchText: String = ""
    
    var body: some View {
        switch selection ?? .translator {
            case .translator:
                GlagoliticTranslatorView(
                    viewModel: glagoliticTranslatorViewModel,
                    isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic
                )
                
            case .history:
                HistoryView(searchText: $searchText)
                
            case .chat:
                ChatView(viewModel: chatViewModel)
            
            case .settings:
                SettingsView()
                
            case .about:
                AboutView()
        }
    }
}

#Preview {
    DetailColumn(
        selection: .constant(.translator),
        glagoliticTranslatorViewModel: GlagoliticTranslatorViewModel(),
        chatViewModel: ChatViewModel(),
        isFromGlagoliticToCyrillic: .constant(false)
    )
}
