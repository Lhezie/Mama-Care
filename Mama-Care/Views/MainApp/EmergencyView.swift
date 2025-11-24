//
//  EmergencyView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//




import SwiftUI

struct EmergencyView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var isSendingAlert = false
    @State private var alertSent = false
    @State private var showingAlertConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    header

                    if alertSent {
                        EmergencySuccessView()
                    } else if isSendingAlert {
                        EmergencySendingView()
                    } else {
                        EmergencyContactsSection()
                        
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .alert("Send Emergency Alert?", isPresented: $showingAlertConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Send Alert", role: .destructive) { sendEmergencyAlert() }
            } message: {
                Text("This will alert all contacts with your location.")
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MamaCare")
                .font(.title)
                .fontWeight(.bold)

            Text("Welcome, \(viewModel.currentUser?.firstName ?? "User")")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    
    
    
    

    // MARK: - Simulated Alert Logic
    private func sendEmergencyAlert() {
        isSendingAlert = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSendingAlert = false
            alertSent = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                alertSent = false
            }
        }
    }
}

struct EmergencySendingView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.red)
            
            VStack(spacing: 12) {
                Text("Sending Emergency Alert...")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Notifying your emergency contacts with your location and emergency details.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}

struct EmergencySuccessView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("Alert Sent Successfully!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your emergency contacts have been notified with your location. Help is on the way.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}
