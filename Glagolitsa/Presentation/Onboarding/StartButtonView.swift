//
//  StartButtonView.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 13.04.2025.
//

import SwiftUI

struct StartButtonView: View {
    
    let color: Color
    @Binding var selectedPageIndex: Int
    @Binding var showingOnboarding: Bool
    
    @AppStorage("isOnboardingCompleted")
    private var isOnboardingCompleted: Bool = false
    
    var body: some View {
        let isLastPage = selectedPageIndex == onboardingPagesData.count - 1
        
        Button {
            if isLastPage {
                isOnboardingCompleted = true
                showingOnboarding = false
            } else {
                withAnimation {
                    selectedPageIndex += 1
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(isLastPage ? "Start" : "Next")
                
                Image(systemName: isLastPage ? "checkmark.circle" : "arrow.right.circle") // 􀁢 : 􀁼
                    .imageScale(.large)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule().strokeBorder(color, lineWidth: 1.25)
            )
        }
        .accentColor(color)
    }
}

#Preview {
    StartButtonView(
        color: .red,
        selectedPageIndex: .constant(0),
        showingOnboarding: .constant(true)
    )
}
