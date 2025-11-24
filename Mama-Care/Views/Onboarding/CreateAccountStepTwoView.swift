//
//  CreateAccountView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//


//








import SwiftUI

struct CreateAccountStepTwoView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel

    var onBack: () -> Void
    var onCreateAccount: () -> Void

    let countries = ["United Kingdom", "Nigeria"]
    let dialCodes = ["+44", "+234"]

    let countryFlags: [String: String] = [
        "Nigeria": "🇳🇬",
        "United Kingdom": "🇬🇧"
        
    ]
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    var body: some View {
        ZStack(alignment: .top) {
            headerView
            
            VStack(spacing: 0) {
                titleSection
                    .padding(.top, 10)

                formContent
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .offset(y: 20)

                Spacer()
            }
        }
        .background(Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98))
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews

    private var headerView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655),
                Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 280)
        .ignoresSafeArea(edges: .top)
    }

    private var titleSection: some View {
        VStack(spacing: 4) {
            Text("Create Account")
                .font(.title)
                .foregroundColor(.white)

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)

                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4))
            }
            .offset(y: 20)
        }
    }

    private var formContent: some View {
        VStack(spacing: 20) {
            progressIndicator

            inputField(
                label: "Email",
                placeholder: "your.email@example.com",
                text: $onboardingVM.user.email
            )

            countryPicker
            mobileNumberInput

            inputField(
                label: "Password",
                placeholder: "Create a strong password",
                text: $onboardingVM.password,
                isSecure: true
            )

            inputField(
                label: "Confirm Password",
                placeholder: "Re-enter your password",
                text: $onboardingVM.confirmPassword,
                isSecure: true
            )
            
            if showError {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, -10)
            }
            
            if showSuccess {
                Text("Account created successfully!")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(.top, -10)
            }

            actionButtons
                .padding(.top, 10)
        }
    }

    private var progressIndicator: some View {
        HStack {
            Circle()
                .fill(Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655))
                .frame(width: 32, height: 32)
                .overlay(Text("1").foregroundColor(.white))

            Rectangle()
                .fill(Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655))
                .frame(height: 2)

            Circle()
                .fill(Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655))
                .frame(width: 32, height: 32)
                .overlay(Text("2").foregroundColor(.white))
        }
    }

    private var countryPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Country")
                .font(.subheadline)
                .fontWeight(.semibold)

            Menu {
                ForEach(countries, id: \.self) { country in
                    Button {
                        onboardingVM.user.country = country
                        if country == "Nigeria" {
                            onboardingVM.selectedDialCode = "+234"
                        } else {
                            onboardingVM.selectedDialCode = "+44"
                        }
                    } label: {
                        Text("\(countryFlags[country] ?? "") \(country)")
                    }
                }
            } label: {
                HStack {
                    Text("\(countryFlags[onboardingVM.user.country] ?? "") \(onboardingVM.user.country)")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }

    private var mobileNumberInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mobile Number")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 8) {
                Menu {
                    ForEach(dialCodes, id: \.self) { code in
                        Button(code) {
                            onboardingVM.selectedDialCode = code
                        }
                    }
                } label: {
                    HStack {
                        Text(onboardingVM.selectedDialCode)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(width: 90)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                TextField("Mobile number", text: $onboardingVM.user.mobileNumber)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button("Back") {
                onBack()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            Button(action: {
                validateAndContinue()
            }) {
                Text("Create Account")
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
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func validateAndContinue() {
        if onboardingVM.user.email.isEmpty || onboardingVM.password.isEmpty || onboardingVM.confirmPassword.isEmpty || onboardingVM.user.mobileNumber.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
            showSuccess = false
            return
        }

        if !isValidEmail(onboardingVM.user.email) {
            errorMessage = "Please enter a valid email"
            showError = true
            showSuccess = false
            return
        }

        if onboardingVM.password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            showSuccess = false
            return
        }

        if onboardingVM.password != onboardingVM.confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            showSuccess = false
            return
        }

        showError = false
        showSuccess = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showSuccess = false
            onCreateAccount()
        }
    }

    // MARK: - Reusable Input Field
    @ViewBuilder
    private func inputField(label: String, placeholder: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)

            if isSecure {
                SecureField(placeholder, text: text)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                TextField(placeholder, text: text)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }
}
