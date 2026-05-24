//
//  PurchaseManager.swift
//  iDelo
//
//  Created by Дмитрiй Канунниковъ on 05.02.2024.
//

import StoreKit
import OSLog
import SwiftData

/// Business logic for in-app purchase
@ModelActor
actor PurchaseManager {
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? Util.getAppDisplayName(),
        category: "PurchaseManager"
    )
    
//    @AppStorage("PurchaseManager.shouldHideCompanies")
//    private var shouldHideCompanies: Bool = false
    
    let userDefaults = UserDefaults.standard
    
    private var updatesTask: Task<Void, Never>?
    private var purchaseIntentsTask: Task<Void, Never>?
    
    private(set) static var shared: PurchaseManager!
    
    static func createSharedInstance(modelContext: ModelContext) {
        shared = PurchaseManager(modelContainer: modelContext.container)
    }
    
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        do {
            let unsafeTransaction = verificationResult.unsafePayloadValue
            logger.log("process() -> Processing transaction ID \(unsafeTransaction.id) for \(unsafeTransaction.productID)")
        }
        
        let transaction: Transaction
        switch verificationResult {
            case .verified(let t):
                logger.debug("""
            process() -> Transaction ID \(t.id) for \(t.productID) is verified
            """)
                transaction = t
            case .unverified(let t, let error):
                // Log failure and ignore unverified transactions
                logger.error("""
            process() -> Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
            """)
                return
        }
        
        // We only need to handle consumables here. We will check the
        // subscription status each time before unlocking a premium subscription
        // feature.
        if case .consumable = transaction.productType {
            
            // The safest practice here is to send the transaction to your
            // server to validate the JWS and keep a ledger of the bird food
            // each account is entitled to. Since this is just a demonstration,
            // we are going to rely on StoreKit's automatic validation and
            // use SwiftData to keep a ledger of the bird food.
            
//            guard let (birdFood, product) = birdFood(for: transaction.productID) else {
//                logger.fault("""
//                Attempting to grant access to \(transaction.productID) for \
//                transaction ID \(transaction.id) but failed to query for
//                corresponding bird food model.
//                """)
//                return
//            }
            
//            let delta = product.quantity * transaction.purchasedQuantity
            
            if transaction.revocationDate == nil, transaction.revocationReason == nil {
                // SwiftData crashes when we do this, so we'll save this for later
                //                if birdFood.finishedTransactions.contains(transaction.id) {
                //                    logger.log("""
                //                    Ignoring unrevoked transaction ID \(transaction.id) for \
                //                    \(transaction.productID) because we have already added \
                //                    \(birdFood.id) for the transaction.
                //                    """)
                //                    return
                //                }
                
                // This doesn't appear to actually be updating the model
//                birdFood.ownedQuantity += delta
                //                birdFood.finishedTransactions.insert(transaction.id)
                
//                logger.log("""
//                Added \(delta) \(birdFood.id)(s) from transaction ID \
//                \(transaction.id). New total quantity: \(birdFood.ownedQuantity)
//                """)
                
                // Finish the transaction after granting the user content
                await transaction.finish()
                
                logger.debug("""
                process() -> Finished transaction ID \(transaction.id) for \
                \(transaction.productID)
                """)
            } else {
//                birdFood.ownedQuantity -= delta
                
//                logger.log("""
//                Removed \(delta) \(birdFood.id)(s) because transaction ID \
//                \(transaction.id) was revoked due to \
//                \(transaction.revocationReason?.localizedDescription ?? "unknown"). \
//                New total quantity: \(birdFood.ownedQuantity).
//                """)
                
                logger.log("""
                process() -> Transaction ID \
                \(transaction.id) was revoked due to \
                \(transaction.revocationReason?.localizedDescription ?? "unknown").
                """)
            }
        } else if case .nonConsumable = transaction.productType {
            if transaction.revocationDate == nil, transaction.revocationReason == nil {
                
                // Finish the transaction after granting the user content
                await transaction.finish()
                
                logger.debug("""
                process() -> Finished transaction ID \(transaction.id) for \
                \(transaction.productID)
                """)
            } else {
                logger.log("""
                process() -> Transaction ID \
                \(transaction.id) was revoked due to \
                \(transaction.revocationReason?.localizedDescription ?? "unknown").
                """)
            }
            
            let currentValue = userDefaults.bool(forKey: "PurchaseManager.isNonConsumableStatusChanged")
            userDefaults.setValue(!currentValue, forKey: "PurchaseManager.isNonConsumableStatusChanged")
        } else {
            // We can just finish the transction since we will grant access to
            // the subscription based on the subscription status.
            await transaction.finish()
        }
        
//        do {
//            try modelContext.save()
//        } catch {
//            logger.error("Could not save model context: \(error.localizedDescription)")
//        }
    }
    
    func checkForUnfinishedTransactions() async {
        logger.debug("checkForUnfinishedTransactions() -> Checking for unfinished transactions")
        for await transaction in Transaction.unfinished {
            let unsafeTransaction = transaction.unsafePayloadValue
            logger.log("""
            checkForUnfinishedTransactions() -> Processing unfinished transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
        logger.debug("checkForUnfinishedTransactions() -> Finished checking for unfinished transactions")
    }
    
    func observeTransactionUpdates() {
        self.updatesTask = Task { [weak self] in
            self?.logger.debug("observeTransactionUpdates() -> Observing transaction updates")
            
            for await update in Transaction.updates {
                guard let self else { break }
                await self.process(transaction: update)
            }
        }
    }
    
    func observePurchaseIntents() {
        self.purchaseIntentsTask = Task { [weak self] in
            self?.logger.debug("observePurchaseIntents() -> Observing purchase intents")
            
            for await purchaseIntent in PurchaseIntent.intents {
                guard let self else { break }
                
                do {
                    let result = try await purchaseIntent.product.purchase()
                    
                    switch result {
                        case .pending:
                            logger.debug("observePurchaseIntents() -> Purchase pending")
                            
                        case .userCancelled:
                            logger.debug("observePurchaseIntents() -> User cancelled")
                            
                        case .success(let transaction):
                            await self.process(transaction: transaction)
                            
                        @unknown default:
                            logger.error("observePurchaseIntents() -> Unknown result")
                    }
                }
                catch {
                    logger.error("observePurchaseIntents(): error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getFinishedTransactions() async {
        for await result in Transaction.currentEntitlements {
            switch result {
                case .verified(let transaction):
                    logger.debug("getFinishedTransactions() -> Transaction ID #\(transaction.id) for product ID #\(transaction.productID) is verified.")
                case .unverified(let transaction, let error):
                    logger.debug("getFinishedTransactions() -> Transaction ID #\(transaction.id) for product ID #\(transaction.productID) is unverified. Error: \(error.localizedDescription)")
            }
            
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                logger.debug("getFinishedTransactions() -> Product ID #\(transaction.productID) is purchased. Grant user access to the paid features.")
                //                purchasedProducts.insert(transaction.productID)
            } else {
                logger.debug("getFinishedTransactions() -> Product ID #\(transaction.productID) is revoked. Block access to the paid features.")
                //                purchasedProducts.remove(transaction.productID)
            }
        }
    }
    
    func purchaseConsumable(
        productId: String,
        onSuccess: @escaping (UInt64) -> Void,
        onFailure: ((UInt64, Error) -> Void)? = nil,
        onPending: (() -> Void)? = nil,
        onUserCancelled: (() -> Void)? = nil
    ) async {
        if let products = try? await Product.products(for: [productId]), let product = products.first {
            let result = try? await product.purchase()
            
            switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                        case .verified(let transaction):
                            logger.info("purchaseConsumable() -> Transaction ID #\(transaction.id) is verified. Give the user access to purchased content.")
                            
                            onSuccess(transaction.id)
                            
                            // Complete the transaction after providing
                            // the user access to the content.
                            await transaction.finish()
                        case .unverified(let transaction, let verificationError):
                            logger.error("purchaseConsumable() -> Transaction ID #\(transaction.id) is not verified: error=\(verificationError.localizedDescription)")
                            onFailure?(transaction.id, verificationError)
                            
                    }
                case .pending:
                    logger.warning("purchaseConsumable() -> The purchase requires action from the customer. If the transaction completes, it's available through Transaction.updates.")
                    onPending?()
                    break
                case .userCancelled:
                    logger.debug("purchaseConsumable() -> The user canceled the purchase.")
                    onUserCancelled?()
                    break
                default:
                    break
            }
        } else {
            logger.error("purchaseConsumable() -> No product with ID #\(productId)")
        }
    }
}

public extension StoreKit.Transaction {
    var isRevoked: Bool {
        // The revocation date is never in the future.
        revocationDate != nil && revocationReason == nil
    }
}
