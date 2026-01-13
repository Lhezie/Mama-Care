//
//  SignInView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 06/11/2025.
//



import SwiftUI
import SwiftData

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = false
    @State private var localUserName: String? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var errorTitle: String = "Login Failed"
    @State private var showResetSent: Bool = false
    
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                //  Background Color (Base Layer)
                Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98, opacity: 1.0) // #F0FDFA
                    .edgesIgnoringSafeArea(.all)
                
                //  Gradient Background Header
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
                    // Offline Indicator Banner
                    if viewModel.isOffline {
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text("Offline - using last synced data")
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.sRGB, red: 1.0, green: 0.6, blue: 0.2, opacity: 1.0)) // Orange
                        .foregroundColor(.white)
                        .transition(.move(edge: .top))
                    }
                    
                    //  Welcome Header Text
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Log in to continue your journey")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)
                    
                    //  Login Card
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            //  Offline Login Option
                            if let name = localUserName {
                                VStack(spacing: 12) {
                                    
//                                    Do not take out this code
                                    Text("Continue as \(name)?")
                                        .font(.headline)
                                        .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0))
                                    
                                    Button(action: {
                                        viewModel.loginLocally()
                                    }) {
                                        HStack {
                                            Image(systemName: "iphone.homebutton")
                                            Text("Continue on this Device")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98)) // Light Mint
                                        .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4).opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    HStack {
                                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                                        Text("OR")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Login to Cloud Account")
                                    .font(.headline)
                                Text("Enter your credentials to sync with cloud")
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
                                    handleForgotPassword()
                                }
                                .font(.subheadline)
                                .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0)) // #009966
                            }
                            
                            // Log In Button
                            Button(action: {
                                errorTitle = "Login Failed"
                                handleLogin()
                            }) {
                                Text("Log In")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            // ALERT for Password Reset (Success)
                            .alert("Reset Email Sent", isPresented: $showResetSent) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("Please check your email to reset your password.")
                            }
                            
                            // ALERT for Errors (Login & Reset)
                            .alert(isPresented: $showError) {
                                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
            }
            .onAppear {
                // Ensure SwiftDataService has the context so it can fetch the user
                SwiftDataService.shared.setModelContext(modelContext)
                localUserName = viewModel.checkForLocalUser()
            }
        }
    }
    //  Checkbox Toggle Style
    struct CheckboxToggleStyle: ToggleStyle {
        func makeBody(configuration: ToggleStyle.Configuration) -> some View {
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

    //  Login Logic
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
                let nsError = error as NSError
                // Firebase error codes for invalid credentials
                if nsError.domain == "com.google.firebase.auth" && (nsError.code == 17009 || nsError.code == 17011 || nsError.code == 17008) {
                    errorMessage = "Invalid email or password. Please try again."
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
            }
        }
    }
    
    private func handleForgotPassword() {
        errorTitle = "Reset Failed"
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address first."
            showError = true
            return
        }
        
        viewModel.sendPasswordResetEmail(email: email) { result in
            switch result {
            case .success:
                showResetSent = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

