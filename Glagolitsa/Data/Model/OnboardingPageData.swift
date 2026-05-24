//
//  OnboardingPageData.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.04.2025.
//

import SwiftUI

struct OnboardingPageData: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let backgroundColors: [Color]
    let foregroundColors: [Color]
}
