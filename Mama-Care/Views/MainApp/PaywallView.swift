//
//  PaywallView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .monthly
    
    enum SubscriptionPlan {
        case monthly
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close Button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.mamaCareDue)
                            
                            Text("Upgrade to Premium")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Unlock all features and get the most out of MamaCare")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(icon: "phone.fill", title: "Emergency Escalation", description: "One-tap emergency alerts to your contacts")
                            FeatureRow(icon: "message.fill", title: "Unlimited AI Chat", description: "24/7 access to AI pregnancy companion")
                            FeatureRow(icon: "bell.badge.fill", title: "Priority Notifications", description: "Never miss important reminders")
                            FeatureRow(icon: "cloud.fill", title: "iCloud Sync", description: "Access your data across all devices")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Detailed insights into your journey")
                            FeatureRow(icon: "heart.text.square.fill", title: "Premium Content", description: "Exclusive tips and resources")
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Pricing Card
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Monthly Plan")
                                        .font(.headline)
                                        .foregroundColor(.mamaCareTextPrimary)
                                    
                                    Text("Cancel anytime")
                                        .font(.caption)
                                        .foregroundColor(.mamaCareTextSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(priceText)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.mamaCarePrimary)
                                    
                                    Text("per month")
                                        .font(.caption)
                                        .foregroundColor(.mamaCareTextSecondary)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Subscribe Button
                            Button {
                                viewModel.purchaseSubscription()
                            } label: {
                                HStack {
                                    Image(systemName: "crown.fill")
                                    Text("Start Premium")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.mamaCareDue, .mamaCareOrange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            // Restore Button
                            Button {
                                viewModel.restorePurchases()
                            } label: {
                                Text("Restore Purchases")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Terms
                        VStack(spacing: 8) {
                            Text("Subscription automatically renews unless cancelled")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 16) {
                                Button("Terms of Service") {}
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Button("Privacy Policy") {}
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    var priceText: String {
        // Get price based on user's country (handle both full names and codes)
        let normalizedCountry = viewModel.userCountry.uppercased()
        let isNigeria = normalizedCountry == "NIGERIA" || normalizedCountry == "NG"
        
        if isNigeria {
            return "₦8,000"
        } else {
            return "£4"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}
