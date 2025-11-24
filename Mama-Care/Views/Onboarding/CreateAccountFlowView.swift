//
//  CreateAccountFlowView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//

//import SwiftUI
//
//struct CreateAccountFlowView: View {
//    @StateObject private var onboardingVM = OnboardingViewModel()
//    @State private var currentStep = 1
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                switch currentStep {
//                case 1:
//                    CreateAccountStepOneView(
//                        onboardingVM: onboardingVM,
//                        onNext: {
//                            currentStep = 2
//                        }
//                    )
//
//                case 2:
//                    CreateAccountStepTwoView(
//                        onboardingVM: onboardingVM,
//                        onBack: {
//                            currentStep = 1
//                        },
//                        onCreateAccount: {
//                            // Proceed to Consent Screen
//                            currentStep = 3
//                        }
//                    )
//
//                case 3:
//                    ConsentScreenView(
//                        onboardingVM: onboardingVM,
//                        onNext: {
//                            // Handle what happens after consent (e.g., finish onboarding or go to main app)
//                            // For now, we might just reset or print
//                            print("Onboarding Flow Completed from CreateAccountFlowView")
//                        },
//                        onBack: {
//                            currentStep = 2
//                        }
//                    )
//                default:
//                    EmptyView()
//                }
//            }
//        }
//    }
//}


import SwiftUI

struct CreateAccountFlowView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()
    @State private var currentStep = 1

    var body: some View {
        NavigationStack {
            currentStepView
        }
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
                    print("✅ CreateAccountFlowView - Moving from Consent to UserTypeSelection")
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
                    print("✅ CreateAccountFlowView - Moving from UserTypeSelection to DateCapture")
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
                    print("✅ CreateAccountFlowView - Moving from DateCapture to EmergencyContacts")
                    currentStep = 6
                },
                onBack: {
                    currentStep = 4
                }
            )
        
        case 6:
            EmergencyContactsView(
                onFinish: {
                    print("✅ CreateAccountFlowView - Completing onboarding")
                    viewModel.completeOnboarding(
                        with: onboardingVM.user,
                        storage: onboardingVM.storageOption,
                        wantsReminders: onboardingVM.wantsReminders
                    )
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
