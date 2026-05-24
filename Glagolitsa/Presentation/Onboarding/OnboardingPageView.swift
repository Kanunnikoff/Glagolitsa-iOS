//
//  OnboardingPageView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.04.2025.
//

import SwiftUI

struct OnboardingPageView: View {
    
    let pageData: OnboardingPageData
    @Binding var selectedPageIndex: Int
    @Binding var showingOnboarding: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text(LocalizedStringKey(pageData.title))
                    .foregroundColor(pageData.foregroundColors[0])
//                    .foregroundStyle(
//                        .linearGradient(
//                            colors: pageData.foregroundColors,
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.horizontal, 16)
//                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 2, x: 2, y: 2)
                
                Text(LocalizedStringKey(pageData.description))
                    .foregroundColor(pageData.foregroundColors[0])
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                StartButtonView(
                    color: pageData.foregroundColors[0],
                    selectedPageIndex: $selectedPageIndex,
                    showingOnboarding: $showingOnboarding
                )
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(pageData.backgroundColors[1])
//        .background(LinearGradient(gradient: Gradient(colors: pageData.backgroundColors), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingPageView(
        pageData: onboardingPagesData[0],
        selectedPageIndex: .constant(0),
        showingOnboarding: .constant(true)
    )
}
