//
//  SettingsView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 19.04.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @Environment(\.dismiss) private var dismiss
    
    // General
    
    @AppStorage("isSplashScreenVisible")
    private var isSplashScreenVisible: Bool = true

    @AppStorage("isConfirmDeletion")
    private var isConfirmDeletion: Bool = true
    
    // Translation
    
#if !os(macOS)
    @AppStorage("isTranslationImageEnabled")
    private var isTranslationImageEnabled: Bool = true
#endif

    @AppStorage(GlagoliticILetter.storageKey)
    private var glagoliticILetter: String = GlagoliticILetter.defaultValue.rawValue
    
    // History
    
//    @AppStorage("isKeepTranslationHistory")
//    private var isKeepTranslationHistory: Bool = true
    
    // Chat
    
//    @AppStorage("isChatTabVisible")
//    private var isChatTabVisible: Bool = true
    
    var body: some View {
        List {
            Section {
                Toggle("Show Splash Screen", isOn: $isSplashScreenVisible)

                Toggle("Confirm Deletion", isOn: $isConfirmDeletion)
                
            } header: {
                Text("General")
            } footer: {
                Text("Basic settings for the entire application.")
            }
            
            Section {
                Picker("Glagolitic Letter for I", selection: $glagoliticILetter) {
                    ForEach(GlagoliticILetter.allCases) { letter in
                        Text(letter.settingsTitle)
                            .tag(letter.rawValue)
                    }
                }

#if !os(macOS)
// TODO: Возможно, вернётся, когда удастся победить проблему с отсутствием боковых отступов у картинки...
                Toggle("Translation Image", isOn: $isTranslationImageEnabled)
#endif
            } header: {
                Text("Translation")
            } footer: {
                Text("Settings for translation between Cyrillic and Glagolitic.")
            }
            
//            Section {
//                Toggle("Keep Translation History", isOn: $isKeepTranslationHistory)
//            } header: {
//                Text("History")
//            } footer: {
//                Text("Settings for storing translation history.")
//            }
            
//            Section {
//                Toggle("Show Chat Tab", isOn: $isChatTabVisible)
//                
//                Toggle("Confirm Deletion", isOn: $isConfirmDeletion)
//            } header: {
//                Text("Chat")
//            } footer: {
//                Text("Various settings for chat.")
//            }
        }
        .navigationTitle("Settings")
        .toolbar {
            if prefersTabNavigation {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark") // 􀆄
                    }
                }
            }
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    SettingsView()
}
