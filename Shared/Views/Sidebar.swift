//
//  Sidebar.swift
//  Sidebar
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

struct Sidebar: View {
    
    @State private var isActive = true
    
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
        }
    }
    
    var content: some View {
        VStack {
            List {
                NavigationLink(destination: MainView(), isActive: $isActive) {
                    Label("Главная", systemImage: "note.text")
                }
                NavigationLink(destination: AboutView()) {
                    Label("О программе", systemImage: "info.circle")
                }
            }
            .listStyle(.sidebar)
        }
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
