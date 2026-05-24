//
//  MainMenuView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 26.10.2025.
//

import SwiftUI

struct MainMenuView: View {
    
    @Binding var sheetType: GlagoliticTranslatorBottomSheetType?
    
    var body: some View {
        Menu {
            Button {
                sheetType = .settings
            } label: {
                Label("Settings", systemImage: "gear") // 􀍟
            }
            
            Button {
                sheetType = .about
            } label: {
                Label("About", systemImage: "info.circle") // 􀅴
            }
        } label: {
            Image(systemName: "ellipsis.circle") // 􀍡
        }
    }
}

#Preview {
    MainMenuView(sheetType: .constant(nil))
}
