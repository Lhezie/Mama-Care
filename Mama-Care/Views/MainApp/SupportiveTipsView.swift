//
//  SupportiveTipsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct SupportiveTipsView: View {
    @Environment(\.dismiss) var dismiss
    var onEmergencyContact: () -> Void
    var onTalkToAI: () -> Void
    var onCalmingAudio: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "FFF0F0") // Light pinkish background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("You're Not Alone")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("We're sorry you're having a difficult time. Your wellbeing matters, and support is available.")
                            .font(.system(size: 16))
                            .foregroundColor(.mamaCareTextDark)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Tips Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Supportive Tips")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TipRow(icon: "heart", text: "Take a few deep breaths and remember that you're doing your best")
                            TipRow(icon: "heart", text: "Gentle movement like a short walk can help improve your mood")
                            TipRow(icon: "heart", text: "Connect with a friend or loved one for support")
                            TipRow(icon: "heart", text: "Stay hydrated and nourish your body with healthy food")
                            TipRow(icon: "heart", text: "Rest when you need to - self-care is essential")
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: onEmergencyContact) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Alert Emergency Contact")
                                Spacer()
                                Image(systemName: "lock")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.mamaCareOverdue) // Red
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: onTalkToAI) {
                                HStack {
                                    Image(systemName: "bubble.left")
                                    Text("Talk to AI")
                                }
                                .foregroundColor(.mamaCareTextPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.mamaCareGrayBorder, lineWidth: 1)
                                )
                            }
                            
                            Button(action: onCalmingAudio) {
                                HStack {
                                    Image(systemName: "music.note")
                                    Text("Calming Audio")
                                }
                                .foregroundColor(.mamaCareTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.mamaCareGrayBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Close Button (X)
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.mamaCareTextSecondary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Emergency Footer
                    VStack {
                        Text("Emergency? Contact your healthcare provider or emergency services immediately if you're in crisis")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "991B1B"))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .background(Color.mamaCareRedLight)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "FCA5A5"), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct TipRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.mamaCarePink) // Pinkish red
                .font(.system(size: 16))
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.mamaCareTextDark)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
