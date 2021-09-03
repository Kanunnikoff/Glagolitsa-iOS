//
//  Util.swift
//  Util
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import UIKit

struct Util {
    
    private init() {
    }
    
    static func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}
