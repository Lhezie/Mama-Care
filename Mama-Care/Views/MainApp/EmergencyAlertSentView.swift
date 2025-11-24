//
//  EmergencyAlertSentView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct EmergencyAlertSentView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Green Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [.mamaCareTeal, .mamaCareTealDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Success Message
                VStack(spacing: 16) {
                    Text("Alert Sent\nSuccessfully!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Your Contact has\nbeen notified of your\nemergency")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                // Details Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("Messages sent to:")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Phone
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.white.opacity(0.6))
                        Text("+447765086256")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("SMS\nSent")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Email
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.6))
                        Text("lizziliana@gmail.com")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("Email\nSent")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Your contact should reach you\nshortly. Stay safe!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
            }
            .padding()
        }
        .onTapGesture {
            dismiss()
        }
    }
}
