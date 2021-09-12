//
//  SettingsView.swift
//  SettingsView
//
//  Created by Kanunnikov Dmitriy Sergeevich on 07.09.2021.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("SettingsView.isSystemFontAndSize")
    private var isSystemFontAndSize: Bool = false
    
    var body: some View {
        Form {
            Toggle("Системный шрифт", isOn: $isSystemFontAndSize)
        }
        .navigationTitle("Настройки")
#if os(macOS)
        .frame(width: 300)
        .padding(80)
#endif
    }
}
