//
//  WelcomeScreenView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct WelcomeScreenView: View {
    var onNext: () -> Void
    var onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Hero Image with Heart Icon
            ZStack(alignment: .topTrailing) {
                Image(systemName: "person.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.mamaCareGrayBorder)
                    .frame(width: 300, height: 300)
                    .background(Color.mamaCareGrayMedium)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                // Heart Icon Overlay
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.mamaCarePink, Color(hex: "F472B6")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .offset(x: 20, y: -20)
            }
            .padding(.bottom, 40)
            
            // Welcome Text
            VStack(spacing: 16) {
                Text("Welcome to MamaCare")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.mamaCareTextPrimary)
                
                Text("Your trusted companion for pregnancy\nand early motherhood. Track your journey\nwith privacy and care.")
                    .font(.system(size: 16))
                    .foregroundColor(.mamaCareTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Navigation Buttons
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button {
                        // Back action (if needed)
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
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
                    
                    Button {
                        onNext()
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mamaCarePrimary)
                        .cornerRadius(12)
                    }
                }
                
                // Login Link
                Button {
                    onLogin()
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(.mamaCareTextSecondary)
                        Text("Log in")
                            .foregroundColor(.mamaCarePrimary)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "F0FDFA").ignoresSafeArea())
    }
}
