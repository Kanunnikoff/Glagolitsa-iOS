//
//  GlagolitsaApp.swift
//  Shared
//
//  Created by Kanunnikov Dmitriy Sergeevich on 02.09.2021.
//

import SwiftUI

@main
struct GlagolitsaApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(macOS)
        .commands {
            ViewCommands()
            
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("О программе")
                }
            }
        }
#endif
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
