//
//  PositiveSupportView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct PositiveSupportView: View {
    @Environment(\.dismiss) var dismiss
    var onTalkToAI: () -> Void
    var onDone: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "FFFBEB") // Light yellow/cream background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("We're Here for You")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("It's okay to not feel great every day. Here are some supportive tips:")
                            .font(.system(size: 16))
                            .foregroundColor(.mamaCareTextDark)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Tips Card
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            TipRow(icon: "sparkles", text: "Take a few deep breaths and remember that you're doing your best")
                            TipRow(icon: "sparkles", text: "Gentle movement like a short walk can help improve your mood")
                            TipRow(icon: "sparkles", text: "Connect with a friend or loved one for support")
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Action Buttons
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
                                    .stroke(Color.mamaCareDue, lineWidth: 1) // Orange border
                            )
                        }
                        
                        Button(action: onDone) {
                            Text("Done")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mamaCareDue) // Orange
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
