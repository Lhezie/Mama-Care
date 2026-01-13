//
//  SubscriptionService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 25/11/2025.
//

import Foundation
import SwiftUI
import StoreKit

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    
    private let productID = "com.mamacare.premium.monthly"
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        // Start transaction listener
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    //  Load Products
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            self.products = products
            print("Loaded \(products.count) product(s)")
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    //  Purchase
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Update subscription status
            await updateSubscriptionStatus()
            
            // Finish the transaction
            await transaction.finish()
            
            print("Purchase successful")
            return transaction
            
        case .userCancelled:
            print("User cancelled purchase")
            return nil
            
        case .pending:
            print("⏳ Purchase pending")
            return nil
            
        @unknown default:
            print("Unknown purchase result")
            return nil
        }
    }
    
    //  Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("Purchases restored")
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    //  Subscription Status
    
    func updateSubscriptionStatus() async {
        var validSubscription: Product? = nil
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this is our subscription
                if transaction.productID == productID {
                    // Find the product
                    if let product = products.first(where: { $0.id == productID }) {
                        validSubscription = product
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        purchasedSubscriptions = validSubscription.map { [$0] } ?? []
        isPremium = validSubscription != nil
        
        print(isPremium ? " User is Premium" : "User is Free")
    }
    
    //  Transaction Listener
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Update subscription status
                    await self.updateSubscriptionStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    //  Verification
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    //  Pricing Info
    
    func getPricing(for country: String) -> String {
        if let product = products.first {
            return product.displayPrice
        }
        
        // Fallback to hardcoded pricing
        switch country.lowercased() {
        case "nigeria":
            return "₦8,000/month"
        case "united kingdom", "uk":
            return "£4/month"
        default:
            return "$5/month"
        }
    }
    
    func getPriceValue(for country: String) -> String {
        if let product = products.first {
            return product.displayPrice
        }
        
        // Fallback
        switch country.lowercased() {
        case "nigeria":
            return "₦8,000"
        case "united kingdom", "uk":
            return "£4"
        default:
            return "$5"
        }
    }
}

//  Store Error

enum StoreError: Error {
    case failedVerification
}
