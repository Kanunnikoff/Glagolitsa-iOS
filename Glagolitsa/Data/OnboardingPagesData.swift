//
//  OnboardingPagesData.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.04.2025.
//

import SwiftUI

let onboardingPagesData: [OnboardingPageData] = [
    OnboardingPageData(
        title: "Добро пожаловать в «Глаголицу»!",
        description: "Приложение для перевода между кириллицей и глаголицей.",
        backgroundColors: [.blue.opacity(0.7), .blue],
        foregroundColors: [.white, .white.opacity(0.7)]
    ),
    OnboardingPageData(
        title: "Что такое глаголица?",
        description: "onboarding_page_2_description",
        backgroundColors: [.white.opacity(0.7), .white],
        foregroundColors: [.black, .black.opacity(0.7)]
    ),
    OnboardingPageData(
        title: "Немного истории",
        description: "onboarding_page_3_description",
        backgroundColors: [.red.opacity(0.7), .red],
        foregroundColors: [.white, .white.opacity(0.7)]
    ),
    OnboardingPageData(
        title: "Что даёт это приложение",
        description: "onboarding_page_4_description",
        backgroundColors: [.yellow.opacity(0.7), .yellow],
        foregroundColors: [.white, .white.opacity(0.7)]
    )
]
