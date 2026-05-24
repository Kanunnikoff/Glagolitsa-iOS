//
//  ContentView.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 02.07.2023.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    
    @AppStorage("isSplashScreenVisible")
    private var isSplashScreenVisible: Bool = true
    
    @State private var selection: SidebarItem? = SidebarItem.translator
    @State private var path = NavigationPath()
    
    @State private var showingSplashScreen: Bool = true
    @State private var glagoliticTranslatorViewModel = GlagoliticTranslatorViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var isFromGlagoliticToCyrillic: Bool = false
    
    var body: some View {
        if isSplashScreenVisible && showingSplashScreen {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeOut(duration: TimeInterval(Config.SPLASH_HIDNG_DURAION_SECONDS))) {
                            showingSplashScreen = false
                        }
                    }
                }
        } else {
            if prefersTabNavigation {
                TabNavigationView(
                    glagoliticTranslatorViewModel: glagoliticTranslatorViewModel,
                    chatViewModel: chatViewModel,
                    isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic
                )
                    .requestReview()
                    .onAppear {
                        // Иначе при включении в Настройках будет сразу показана заставка
                        showingSplashScreen = false
                    }
            } else {
                NavigationSplitView {
                    Sidebar(selection: $selection)
                } detail: {
                    NavigationStack(path: $path) {
                        DetailColumn(
                            selection: $selection,
                            glagoliticTranslatorViewModel: glagoliticTranslatorViewModel,
                            chatViewModel: chatViewModel,
                            isFromGlagoliticToCyrillic: $isFromGlagoliticToCyrillic
                        )
                    }
                }
                .onChange(of: selection) {
                    path.removeLast(path.count)
                }
                .requestReview()
                .onAppear {
                    // Иначе при включении в Настройках будет сразу показана заставка
                    showingSplashScreen = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
