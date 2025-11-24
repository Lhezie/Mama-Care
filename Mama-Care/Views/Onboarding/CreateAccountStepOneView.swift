//
//  CreateAccountStepOneView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//

import SwiftUI

struct CreateAccountStepOneView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    let onNext: () -> Void
    @State private var showValidationError = false

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Gradient Header Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655),
                    Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 260)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // MARK: - Title Header
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("Let’s get started with your details")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 20)

                // MARK: - Floating Form Card
                VStack(spacing: 20) {
                    // Step Indicator
                    HStack {
                        Circle()
                            .fill(Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655))
                            .frame(width: 32, height: 32)
                            .overlay(Text("1").foregroundColor(.white))

                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 2)

                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 32, height: 32)
                            .overlay(Text("2").foregroundColor(.white))
                    }

                    // Section Title
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Information")
                            .font(.headline)

                        Text("Please enter your personal information. This will be used to personalize your experience.")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // Input Fields
                        VStack(spacing: 16) {
                            inputField(label: "First Name", placeholder: "Enter your first name", text: $onboardingVM.user.firstName)
                            inputField(label: "Last Name", placeholder: "Enter your last name", text: $onboardingVM.user.lastName)
                        }
                    }
                    
                    if showValidationError {
                        Text("Please fill in both first and last name.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Continue Button
                    Button(action: {
                        if onboardingVM.isPersonalInfoValid {
                            showValidationError = false
                            onNext()
                        } else {
                            showValidationError = true
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655),
                                        Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .offset(y: 40)

                Spacer()
            }
        }
        .background(Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98)) // #F0FDFA
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func inputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
            TextField(placeholder, text: text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(showValidationError && text.wrappedValue.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                )
        }
    }
}
