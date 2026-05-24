//
//  UIColorExt.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 11.05.2025.
//

#if !os(macOS)
import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
#endif
