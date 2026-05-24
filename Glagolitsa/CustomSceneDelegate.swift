//
//  CustomSceneDelegate.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 26.03.2025.
//

#if !os(macOS)
import UIKit
import SwiftUI

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == QuickAction.deleteFeedback.rawValue {
            QuickActionsManager.shared.handleItem(shortcutItem)
        }
    }
}
#endif
