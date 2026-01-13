//
//  PaywallView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 25/11/2025.
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPurchasing = false
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Upgrade to Premium")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Unlock all features and get the most out of MamaCare")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Features List
                    VStack(spacing: 20) {
                        FeatureRow(
                            icon: "bell.badge.fill",
                            title: "Emergency Escalation",
                            description: "Automatic alerts to emergency contacts when you need help"
                        )
                        
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Advanced Mood Analytics",
                            description: "Detailed insights and trends about your emotional wellbeing"
                        )
                        
                        FeatureRow(
                            icon: "message.fill",
                            title: "Priority AI Support",
                            description: "Get faster responses from our AI health assistant"
                        )
                        
                        FeatureRow(
                            icon: "cloud.fill",
                            title: "Unlimited Cloud Sync",
                            description: "Sync your data across all your devices seamlessly"
                        )
                        
                        FeatureRow(
                            icon: "lock.shield.fill",
                            title: "Enhanced Privacy",
                            description: "Extra security features to protect your sensitive data"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Pricing
                    VStack(spacing: 12) {
                        Text(subscriptionService.getPriceValue(for: viewModel.currentUser?.country ?? "United Kingdom"))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.mamaCarePrimary)
                        
                        Text("per month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Cancel anytime")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Purchase Button
                    Button {
                        purchasePremium()
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Start Premium")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mamaCarePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal)
                    
                    // Restore Button
                    Button {
                        restorePurchases()
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.mamaCarePrimary)
                    }
                    
                    // Terms
                    Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .alert("Welcome to Premium! 🎉", isPresented: $showSuccess) {
            Button("Continue") {
                updateUserPremiumStatus()
                dismiss()
            }
        } message: {
            Text("You now have access to all premium features. Enjoy!")
        }
    }
    
    //  Actions
    
    private func purchasePremium() {
        guard let product = subscriptionService.products.first else {
            print("No product available")
            return
        }
        
        isPurchasing = true
        
        Task {
            do {
                let transaction = try await subscriptionService.purchase(product)
                
                if transaction != nil {
                    // Purchase successful
                    showSuccess = true
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            
            isPurchasing = false
        }
    }
    
    private func restorePurchases() {
        Task {
            await subscriptionService.restorePurchases()
            
            if subscriptionService.isPremium {
                showSuccess = true
            }
        }
    }
    
    private func updateUserPremiumStatus() {
        viewModel.updatePremiumStatus(isPremium: subscriptionService.isPremium)
    }
}

//  Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.mamaCarePrimary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(MamaCareViewModel())
}
