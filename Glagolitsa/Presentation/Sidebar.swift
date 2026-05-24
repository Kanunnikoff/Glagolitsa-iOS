//
//  Sidebar.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 19.04.2025.
//

import SwiftUI
import Combine

struct Sidebar: View {
    
    @AppStorage("isKeepTranslationHistory")
    private var isKeepTranslationHistory: Bool = true
    
    @AppStorage("isChatTabVisible")
    private var isChatTabVisible: Bool = true
    
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: SidebarItem.translator) {
                Label("Translator", systemImage: "character.bubble") // 􀌰
            }
            
            if isChatTabVisible {
                NavigationLink(value: SidebarItem.chat) {
                    Label("Chat", systemImage: "ellipsis.message") // 􁒘
                }
            }
            
            if isKeepTranslationHistory {
                NavigationLink(value: SidebarItem.history) {
                    Label("History", systemImage: "clock") // 􀐫
                }
            }
            
            NavigationLink(value: SidebarItem.settings) {
                Label("Settings", systemImage: "gear") // 􀍟
            }
            
            NavigationLink(value: SidebarItem.about) {
                Label("About", systemImage: "info.circle") // 􀅴
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Menu")
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
#endif
    }
}

#Preview {
    Sidebar(selection: .constant(.translator))
}
