//
//  iDeloShopViewModifier.swift
//  iDelo
//
//  Created by Дмитрiй Канунниковъ on 05.02.2024.
//

import SwiftUI

struct TipsViewModifier: ViewModifier {
    
    @Binding var showingTipsPurchasedIndicator: Bool
    @Binding var showingTipsPurchaseErrorAlert: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .containerShape(.rect(cornerRadius: 20))
        .overlay(alignment: .bottom) {
            if showingTipsPurchasedIndicator {
                DoneIndicatorView(
                    message: "Thank you so much for your support!",
                    startImageName: "dollarsign",
                    endImageName: "heart.fill"
                )
            }
        }
        .alert(
            "Error",
            isPresented: $showingTipsPurchaseErrorAlert,
            actions: {
                Button("OK", role: .cancel) {
                    // nothing to do
                }
            },
            message: {
                Text("I really appreciate your good intention, but for some reason the purchase could not be completed... If you do not change your mind about supporting me, then please try again later.")
            }
        )
    }
}

extension View {
    
    func tips(
        showingTipsPurchasedIndicator: Binding<Bool>,
        showingTipsPurchaseErrorAlert: Binding<Bool>
    ) -> some View {
        modifier(
            TipsViewModifier(
                showingTipsPurchasedIndicator: showingTipsPurchasedIndicator,
                showingTipsPurchaseErrorAlert: showingTipsPurchaseErrorAlert
            )
        )
    }
}
