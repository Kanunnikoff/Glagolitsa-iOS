//
//  SortingMenuButtonTip.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 18.03.2025.
//

import SwiftUI
import TipKit

struct MenuButtonTip: Tip {
    
    var id: String {
        "MenuTip"
    }
    
    var title: Text {
        Text("Menu")
    }
    
    var message: Text? {
        Text("Opens a menu where you can select a dictionary, sort direction, filtering, spelling, and download new dictionaries.")
    }
    
    var image: Image? {
        Image(systemName: "ellipsis.circle") // 􀍡
    }
}
