//
//  OnboardingFlowView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 06/11/2025.
//




// OnboardingFlowView.swift
import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()

    @State private var step: OnboardingStep = .personalInfo
    @State private var onboardingError: String?
    @State private var showOnboardingError = false
    @State private var isEmailTakenError = false
    @State private var isRegistering = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            Group {
                switch step {
                case .personalInfo:
                    CreateAccountStepOneView(
                        onboardingVM: onboardingVM,
                        onNext: handlePersonalInfo
                    )
                case .accountInfo:
                    CreateAccountStepTwoView(
                        onboardingVM: onboardingVM,
                        onBack: goBack,
                        onCreateAccount: handleAccountInfo
                    )
                case .consent:
                    ConsentScreenView(
                        onboardingVM: onboardingVM,
                        onNext: handleConsent,
                        onBack: goBack
                    )
                case .userType:
                    UserTypeSelectionView(
                        onboardingVM: onboardingVM,
                        onNext: handleUserType,
                        onBack: goBack
                    )
                case .dateCapture:
                    DateCaptureView(
                        onboardingVM: onboardingVM,
                        onNext: handleDateCapture,
                        onBack: goBack
                    )
                case .emergencyContacts:
                    EmergencyContactsView(
                        onFinish: completeOnboarding,
                        onBack: goBack
                    )

                }
            }
            .environmentObject(viewModel)
            .environmentObject(onboardingVM)
            
            if isRegistering {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Creating account...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
        .alert("Account Creation Failed", isPresented: $showOnboardingError) {
            if isEmailTakenError {
                Button("Sign In Instead") {
                    // Logic to jump to Sign In
                    viewModel.hasCompletedOnboarding = true 
                    // This is a bit hacky, but setting this will likely take the user out of onboarding
                    // and since they aren't logged in, they'll see the Sign In screen if the app root handles it.
                }
                Button("Use Different Email", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(onboardingError ?? "An unknown error occurred. Please try again.")
        }
    }

    //  Navigation Handlers

    //  Navigation Handlers

    private func handlePersonalInfo() {
        if onboardingVM.isPersonalInfoValid {
            // New Flow: Personal Info -> Consent
            step = .consent
        } else {
            onboardingVM.showPersonalInfoError = true
        }
    }
    
    // New handler for Consent Step
    private func handleConsent() {
        print("OnboardingFlowView - handleConsent called")
        
        if onboardingVM.canCompleteAccount {
            print("Validation passed. Storage Mode: \(String(describing: onboardingVM.storageOption))")
            onboardingVM.user.privacyAcceptedAt = Date()
            
            // Branching Logic
            if onboardingVM.storageOption == .deviceOnly {
                // Skip Account Info (Email/Pass)
                step = .userType
            } else {
                // Cloud users need Account Info
                step = .accountInfo
            }
        } else {
             onboardingVM.showConsentError = true
        }
    }

    private func handleAccountInfo() {
        if onboardingVM.isAccountInfoValid {
             // Cloud Flow: After account info, go to UserType (Consent already done)
             step = .userType
        } else {
            onboardingVM.showAccountInfoError = true
        }
    }

    private func handleUserType() {
        if onboardingVM.user.userType != nil {
            step = .dateCapture
        }
    }

    private func handleDateCapture() {
        if onboardingVM.isDateValid {
            step = .emergencyContacts
        } else {
            onboardingVM.showDateError = true
        }
    }

    private func completeOnboarding() {
        isRegistering = true
        onboardingError = nil
        isEmailTakenError = false
        
        viewModel.completeOnboarding(
            with: onboardingVM.user,
            password: onboardingVM.password,
            storage: onboardingVM.storageOption,
            wantsReminders: onboardingVM.wantsReminders
        ) { result in
            isRegistering = false
            switch result {
            case .success:
                print("Onboarding flow completed successfully")
            case .failure(let error):
                let nsError = error as NSError
                // Firebase error code for email already in use
                if nsError.domain == "com.google.firebase.auth" && nsError.code == 17007 {
                    isEmailTakenError = true
                    onboardingError = "This email is already associated with an account. Would you like to sign in instead?"
                } else {
                    onboardingError = error.localizedDescription
                }
                showOnboardingError = true
            }
        }
    }

    private func goBack() {
        switch step {
        case .consent:
            step = .personalInfo
            
        case .accountInfo:
            // Only Cloud users see this, so back takes them to Consent
            step = .consent
            
        case .userType:
            // Logic depends on storage mode
            if onboardingVM.storageOption == .deviceOnly {
                step = .consent
            } else {
                step = .accountInfo
            }
            
        case .dateCapture:
            step = .userType
            
        case .emergencyContacts:
            step = .dateCapture
            
        default:
            break
        }
    }
}

enum OnboardingStep {
    case personalInfo, accountInfo, consent, userType, dateCapture, emergencyContacts
}





