//
//  EmergencyContactSelectionView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 27/11/2025.
//

import SwiftUI
import MessageUI

struct EmergencyContactSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var showMessageComposer = false
    @State private var selectedContact: EmergencyContact?
    @State private var showSimulatorAlert = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.mamaCarePrimary)
                        .padding(.top, 20)
                    
                    Text("Select Emergency Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.mamaCareTextPrimary)
                    
                    Text("Choose who you'd like to contact")
                        .font(.subheadline)
                        .foregroundColor(.mamaCareTextSecondary)
                }
                .padding()
                
                // Premium Banner for non-premium users
                if viewModel.currentUser?.isPremium != true {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Premium Feature")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Upgrade") {
                            showPaywall = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.mamaCarePrimary)
                    }
                    .padding()
                    .background(Color.mamaCareGrayLight)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Contact List
                if viewModel.emergencyContacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.mamaCareTextTertiary)
                        
                        Text("No Emergency Contacts")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("Add emergency contacts in Settings")
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.emergencyContacts) { contact in
                                ContactCard(
                                    contact: contact,
                                    onMessage: {
                                        if MFMessageComposeViewController.canSendText() {
                                            selectedContact = contact
                                            showMessageComposer = true
                                        } else {
                                            showSimulatorAlert = true
                                        }
                                    },
                                    isPremium: viewModel.currentUser?.isPremium ?? false,
                                    onUpgrade: {
                                        showPaywall = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                // Cancel Button
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.mamaCareTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mamaCareGrayLight)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showMessageComposer) {
                if let contact = selectedContact {
                    MessageComposeView(
                        recipient: contact.phoneNumber,
                        body: "Hi \(contact.name), I'm not feeling great right now and wanted to reach out. - Sent from MamaCare"
                    )
                }
            }
            .alert("Messaging Not Available", isPresented: $showSimulatorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("SMS messaging is only available on a real iPhone device. Please test this feature on a physical device.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct ContactCard: View {
    let contact: EmergencyContact
    let onMessage: () -> Void
    let isPremium: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Contact Info
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.mamaCarePrimary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text(contact.relationship)
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                        
                        Text(contact.phoneNumber)
                            .font(.caption)
                            .foregroundColor(.mamaCareTextTertiary)
                    }
                    
                    Spacer()
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { 
                    if isPremium {
                        callContact(contact)
                    } else {
                        onUpgrade()
                    }
                }) {
                    HStack {
                        Image(systemName: isPremium ? "phone.fill" : "lock.fill")
                        Text("Call")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPremium ? Color.mamaCareCompleted : Color.secondary)
                    .cornerRadius(10)
                }
                
                Button(action: { 
                    if isPremium {
                        onMessage()
                    } else {
                        onUpgrade()
                    }
                }) {
                    HStack {
                        Image(systemName: isPremium ? "message.fill" : "lock.fill")
                        Text("Message")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPremium ? Color.mamaCarePrimary : Color.secondary)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func callContact(_ contact: EmergencyContact) {
        let cleanNumber = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot make phone calls on this device")
        }
    }
}

//  Message Composer
struct MessageComposeView: UIViewControllerRepresentable {
    let recipient: String
    let body: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = [recipient]
        controller.body = body
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            dismiss()
        }
    }
}
