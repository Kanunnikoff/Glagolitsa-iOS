//
//  ViewExt.swift
//  ViewExt
//
//  Created by Kanunnikov Dmitriy Sergeevich on 03.09.2021.
//

import SwiftUI

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
