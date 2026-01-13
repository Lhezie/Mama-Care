//
//  EmergencyView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI

struct EmergencyView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSendingAlert = false // Used for simulator fallback or automated "processing" state
    @State private var alertSent = false
    @State private var showingAlertConfirmation = false
    @State private var isShowingMessageComposer = false
    @State private var alertError: String?
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    header

                    if alertSent {
                        EmergencySuccessView {
                            // Reset or dismiss if presented modally
                            alertSent = false
                            if viewModel.showEmergencyEscalation {
                                viewModel.showEmergencyEscalation = false
                            }
                        }
                    } else {
                        EmergencyContactsSection()
                    }
                    
                    // Show error if any
                    if let error = alertError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .alert("Send Emergency Alert?", isPresented: $showingAlertConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Send Alert", role: .destructive) { sendEmergencyAlert() }
            } message: {
                Text("This will compose a message to your emergency contacts with your status.")
            }
            .sheet(isPresented: $isShowingMessageComposer) {
                MessageComposerView(
                    recipients: viewModel.emergencyContacts.filter { $0.hasContactInfo }.map { $0.phoneNumber },
                    body: "Help! I haven't checked in for 48 hours. Please check on me."
                ) { result in
                    // Handle result
                    switch result {
                    case .sent:
                        alertSent = true
                    case .failed:
                        alertError = "Failed to send message."
                    case .cancelled:
                        break
                    @unknown default:
                        break
                    }
                }
            }
            // If opened via escalation, auto-trigger the flow
            .onAppear {
                if viewModel.showEmergencyEscalation {
                     // Check if we haven't already acted
                     if !alertSent && !isSendingAlert && !isShowingMessageComposer {
                         // Check premium status before auto-escalation
                         if viewModel.currentUser?.isPremium == true {
                             sendEmergencyAlert()
                         } else {
                             // Show paywall for non-premium users
                             showPaywall = true
                         }
                     }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(viewModel)
            }
        }
    }

    //  Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MamaCare")
                .font(.title)
                .fontWeight(.bold)

            Text("Welcome, \(viewModel.currentUser?.firstName ?? "User")")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if viewModel.showEmergencyEscalation {
                Text("Escalation triggered due to inactivity.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    //  Alert Logic
    private func sendEmergencyAlert() {
        alertError = nil
        
        // 0. Check premium status
        guard viewModel.currentUser?.isPremium == true else {
            showPaywall = true
            return
        }
        
        // 1. Check if device can send text
        if MessageComposerView.canSendText() {
            // 2. Check if we have contacts
            let contacts = viewModel.emergencyContacts.filter { $0.hasContactInfo && !$0.phoneNumber.isEmpty }
            
            if !contacts.isEmpty {
                isShowingMessageComposer = true
            } else {
                alertError = "No contacts with phone numbers found."
            }
        } else {
            // Simulator / No-Cellular Fallback
            // User requested no simulation. Just show error.
            print("Device cannot send text.")
            alertError = "SMS not available on this device."
        }
    }
}

struct EmergencySuccessView: View {
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("Alert Processed!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your emergency message has been handled.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let onDismiss = onDismiss {
                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}
