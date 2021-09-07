//
//  UIViewExt.swift
//  UIViewExt
//
//  Created by Kanunnikov Dmitriy Sergeevich on 06.09.2021.
//

import UIKit

extension UIView {
    
    func asImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }
}
