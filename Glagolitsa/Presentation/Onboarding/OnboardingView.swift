//
//  OnboardingView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 12.04.2025.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var showingOnboarding: Bool
    
    @State private var selectedPageIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedPageIndex) {
            ForEach(Array(onboardingPagesData.enumerated()), id: \.element) { index, pageData in
                OnboardingPageView(
                    pageData: pageData,
                    selectedPageIndex: $selectedPageIndex,
                    showingOnboarding: $showingOnboarding
                )
                .tag(index)
            }
        }
#if !os(macOS)
        .tabViewStyle(.page)
#endif
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingView(showingOnboarding: .constant(true))
}
