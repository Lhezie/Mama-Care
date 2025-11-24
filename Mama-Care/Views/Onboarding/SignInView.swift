//
//  SignInView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//



import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: - Gradient Background Header
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655, opacity: 1.0),
                        Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 260)
                .edgesIgnoringSafeArea(.top)
                
                VStack(spacing: 0) {
                    // MARK: - Welcome Header Text
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Log in to continue your journey")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Login Card
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Login to Your Account")
                                .font(.headline)
                            Text("Enter your credentials to access your personal care dashboard")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Email Field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("your.email@example.com", text: $email)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        
                        // Password Field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
                            }
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        
                        // Remember me and Forgot
                        HStack {
                            Toggle(isOn: $rememberMe) {
                                Text("Remember me")
                                    .font(.subheadline)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            
                            Spacer()
                            
                            Button("Forgot password?") {
                                // Add forgot logic
                            }
                            .font(.subheadline)
                            .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0)) // #009966
                        }
                        
                        // Log In Button
                        Button(action: {
                            handleLogin()
                        }) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .alert(isPresented: $showError) {
                            Alert(title: Text("Login Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        // Divider
                        HStack {
                            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                            Text("or")
                                .foregroundColor(.gray)
                            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                        }
                        
                        // Sign up
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            NavigationLink(destination: CreateAccountFlowView()){
                                
                                Text("Sign up")
                                    .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0))
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .offset(y: 40)
                    
                    Spacer()
                }
            }
            .background(Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98, opacity: 1.0)) // #F0FDFA
        }
    }
    
    // MARK: - Checkbox Toggle Style
    struct CheckboxToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            Button(action: { configuration.isOn.toggle() }) {
                HStack {
                    Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                        .foregroundColor(configuration.isOn ? Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0) : .gray) // #009966
                    configuration.label
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    
    // MARK: - Login Logic
    private func handleLogin() {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            showError = true
            return
        }
        
        // Call Firebase Login
        viewModel.login(email: email, password: password) { result in
            switch result {
            case .success:
                // Login successful, ViewModel handles state update
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
