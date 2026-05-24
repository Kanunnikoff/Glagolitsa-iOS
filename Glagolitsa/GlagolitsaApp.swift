//
//  GlagolitsaApp.swift
//  Glagolitsa
//
//  Created by Дмитрiй Канунниковъ on 02.07.2023.
//

import SwiftUI
import TipKit
import FirebaseCore

@main
struct GlagolitsaApp: App {

#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .shop()
#if os(macOS)
            // Такие размеры используем для последующего создания снимков экрана для App Store
            //                .frame(width: 1280, height: 706)
                .frame(minWidth: 1280, minHeight: 800)
#endif
                .task {
                    if Config.isTestMode {
                        // Show all defined tips in the app.
                        // Tips.showAllTipsForTesting()

                        // Purge all TipKit-related data and reset the state of all tips.
                        // try? Tips.resetDatastore()
                    }

                    // Configure and load your tips at app launch.
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(for: Translation.self)
    }
}
