//
//  Util.swift
//  Util
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct Util {
    
    private init() {
    }
    
    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }
}
