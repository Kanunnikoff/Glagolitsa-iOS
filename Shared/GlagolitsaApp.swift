//
//  GlagolitsaApp.swift
//  Shared
//
//  Created by Kanunnikov Dmitriy Sergeevich on 02.09.2021.
//

import SwiftUI

@main
struct GlagolitsaApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(macOS)
        .commands {
            ViewCommands()
        }
#endif

    }
}
