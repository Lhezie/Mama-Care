//
//  EmergencyContactRow.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 04/11/2025.
//


import SwiftUI

struct EmergencyContactRow: View {
    let contact: EmergencyContact

    @State private var showingSimulatorError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Name + Relationship badge
            HStack(alignment: .center) {
                Text(contact.name)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Text(contact.relationship)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.mamaCarePrimary.opacity(0.1))
                    .foregroundColor(Color.mamaCarePrimary)
                    .clipShape(Capsule())
            }

            // Phone & Actions
            if !contact.phoneNumber.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    // Number display
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Text(contact.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Call Button
                        Button {
                            let cleaned = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                errorMessage = "Feature Unavailable: Calling/Messaging is not supported on Simulator. 
                                You must use an actual iPhone."
                                showingSimulatorError = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                        
                        // Message Button
                        Button {
                            let cleaned = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if let url = URL(string: "sms://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                errorMessage = "Feature Unavailable: Calling/Messaging is not supported on Simulator. 
                                You must use an actual iPhone."
                                showingSimulatorError = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Message")
                            }
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                }
            }

            // Email
            if !contact.email.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                    Text(contact.email)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .alert("Feature Unavailable", isPresented: $showingSimulatorError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}
