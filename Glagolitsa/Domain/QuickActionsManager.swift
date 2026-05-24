//
//  QuickActionsManager.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 26.03.2025.
//

#if !os(macOS)
import Foundation
import UIKit

enum QuickAction: String {
    case deleteFeedback = "software.kanunnikoff.Glagolitsa.DeleteFeedback"
    
    static func from(rawValue: String) -> QuickAction? {
        return QuickAction(rawValue: rawValue)
    }
}

class QuickActionsManager {
    
    static let shared = QuickActionsManager()
    
    private init() {}
    
    func handleItem(_ item: UIApplicationShortcutItem) {
        guard let actionItem = QuickAction.from(rawValue: item.type) else { return }
        
        switch actionItem {
            case .deleteFeedback:
                let subject = "Delete Feedback for \(Util.getAppDisplayName()) v\(Util.getAppVersion()) b\(Util.getAppBuild())"
                let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let urlString = "mailto:\(Config.DEVELOPER_EMAIL)?subject=\(encodedSubject)"
                
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        debugPrint("Can't open url on this device")
                    }
                }
        }
        
    }
}
#endif
