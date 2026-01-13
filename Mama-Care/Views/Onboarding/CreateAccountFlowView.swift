//
//  CreateAccountFlowView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 06/11/2025.


import SwiftUI

struct CreateAccountFlowView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()
    @State private var currentStep = 1

    var body: some View {
        currentStepView
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case 1:
            CreateAccountStepOneView(
                onboardingVM: onboardingVM,
                onNext: {
                    currentStep = 2
                }
            )

        case 2:
            CreateAccountStepTwoView(
                onboardingVM: onboardingVM,
                onBack: {
                    currentStep = 1
                },
                onCreateAccount: {
                    currentStep = 3
                }
            )

        case 3:
            ConsentScreenView(
                onboardingVM: onboardingVM,
                onNext: {
                    print("CreateAccountFlowView - Moving from Consent to UserTypeSelection")
                    currentStep = 4
                },
                onBack: {
                    currentStep = 2
                }
            )
        
        case 4:
            UserTypeSelectionView(
                onboardingVM: onboardingVM,
                onNext: {
                    print("CreateAccountFlowView - Moving from UserTypeSelection to DateCapture")
                    currentStep = 5
                },
                onBack: {
                    currentStep = 3
                }
            )
        
        case 5:
            DateCaptureView(
                onboardingVM: onboardingVM,
                onNext: {
                    print("CreateAccountFlowView - Moving from DateCapture to EmergencyContacts")
                    currentStep = 6
                },
                onBack: {
                    currentStep = 4
                }
            )
        
        case 6:
            EmergencyContactsView(
                onFinish: {
                    print("CreateAccountFlowView - Completing onboarding")
                    viewModel.completeOnboarding(
                        with: onboardingVM.user,
                        password: onboardingVM.password,
                        storage: onboardingVM.storageOption,
                        wantsReminders: onboardingVM.wantsReminders
                    ) { _ in }
                },
                onBack: {
                    currentStep = 5
                }
            )
            .environmentObject(onboardingVM)
            
        default:
            EmptyView()
        }
    }
}
