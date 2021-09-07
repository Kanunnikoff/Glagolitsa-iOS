//
//  SizePreferenceKey.swift
//  SizePreferenceKey
//
//  Created by Kanunnikov Dmitriy Sergeevich on 07.09.2021.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
