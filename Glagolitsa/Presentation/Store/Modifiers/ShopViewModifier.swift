//
//  iDeloShopViewModifier.swift
//  iDelo
//
//  Created by Дмитрiй Канунниковъ on 05.02.2024.
//

import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? Util.getAppDisplayName(),
    category: "ShopViewModifier"
)

struct ShopViewModifier: ViewModifier {
    
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .onAppear {
            PurchaseManager.createSharedInstance(modelContext: modelContext)
        }
        .task {
            logger.debug("Starting tasks to observe transaction updates")
            
            // Begin observing StoreKit transaction updates in case a
            // transaction happens on another device.
            await PurchaseManager.shared.observeTransactionUpdates()
            
            // Listens for purchase intents from the App Store
            await PurchaseManager.shared.observePurchaseIntents()
            
            // Check if we have any unfinished transactions where we
            // need to grant access to content
            await PurchaseManager.shared.checkForUnfinishedTransactions()
            
            logger.debug("Finished checking for unfinished transactions")
        }
    }
}

extension View {
    
    func shop() -> some View {
        modifier(ShopViewModifier())
    }
}
