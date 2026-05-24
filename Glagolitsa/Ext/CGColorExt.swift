//
//  CGColorExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 11.05.2025.
//

#if !os(macOS)
import UIKit

extension CGColor {
    
    class func colorWithHex(hex: Int) -> CGColor {
        return UIColor(hex: hex).cgColor
    }
}
#endif
