//
//  RequestReviewViewModifier.swift
//  Glagolitsa
//
//  Created by Kanunnikov Dmitriy  on 17.03.2025.
//

import SwiftUI
import OSLog

private let logger = MyLogger(category: "RequestReviewViewModifier")

struct RequestReviewViewModifier: ViewModifier {
    
#if !os(tvOS) && !os(watchOS)
    @AppStorage("RequestReviewViewModifier.launchesCount")
    private var launchesCount: Int = 0
    
    @AppStorage("RequestReviewViewModifier.lastVersionPromtedForReview")
    private var lastVersionPromtedForReview: String = ""
    
    @Environment(\.requestReview) var requestReview
#endif
    
    func body(content: Content) -> some View {
        content
#if !os(tvOS) && !os(watchOS)
            .onAppear {
                requestReviewIfNeeded()
            }
#endif
    }
    
#if !os(tvOS) && !os(watchOS)
    private func requestReviewIfNeeded() {
        launchesCount += 1
        
        // Get the current bundle version for the app
        let currentVersion = Util.getAppBuild()
        
        // Has the process been completed several times and the user has not already been prompted for this version?
        if launchesCount >= Config.REQUEST_REVIEW_LAUNCHES_COUNT_THRESHOLD && currentVersion != lastVersionPromtedForReview {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                requestReview()
                lastVersionPromtedForReview = currentVersion
            }
        }
    }
#endif
}

extension View {
    
    func requestReview() -> some View {
        modifier(RequestReviewViewModifier())
    }
}
