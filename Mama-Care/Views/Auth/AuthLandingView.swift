//
//  AuthLandingView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 04/11/2025.
//



import SwiftUI

import SwiftUI

struct AuthLandingView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var navigateToSignIn = false
    @State private var navigateToCreateAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                // App Logo and Branding
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.mamaCareGradient)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("MamaCare")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(Color.mamaCareGradient)
                        
                        Text("Your Pregnancy & Child Health Companion")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
                
                Spacer()
                
                // Navigation Buttons
                VStack(spacing: 16) {
                    NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                        Button("Sign In") {
                            navigateToSignIn = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    NavigationLink(destination: CreateAccountFlowView(), isActive: $navigateToCreateAccount) {
                        Button("Create Account") {
                            navigateToCreateAccount = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                // Privacy Policy
                Text("By continuing you agree to our Privacy Policy and Terms.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}
