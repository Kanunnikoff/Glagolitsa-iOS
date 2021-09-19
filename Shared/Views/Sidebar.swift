//
//  Sidebar.swift
//  Sidebar
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

struct Sidebar: View {
    
    @State private var selection: String? = "Main"
    
    @ViewBuilder
    var body: some View {
        NavigationView {
#if os(iOS)
            content
                .navigationTitle("Меню")
#else
            content
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
#endif
            
            MainView().environmentObject(MainViewModel.shared)
        }
    }
    
    var content: some View {
        List {
            NavigationLink(destination: MainView().environmentObject(MainViewModel.shared), tag: "Main", selection: $selection) {
                Label("Главная", systemImage: "note.text")
            }
#if os(iOS)
            NavigationLink(destination: SettingsView(), tag: "Settings", selection: $selection) {
                Label("Настройки", systemImage: "gear")
            }
            
            NavigationLink(destination: AboutView(), tag: "About", selection: $selection) {
                Label("О программе", systemImage: "info.circle")
            }
#endif
        }
//        .listStyle(.sidebar)
        .listStyle(SidebarListStyle())
    }
}

#if DEBUG
struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Sidebar()
                .preferredColorScheme(.light)
            Sidebar()
                .preferredColorScheme(.dark)
        }
    }
}
#endif
