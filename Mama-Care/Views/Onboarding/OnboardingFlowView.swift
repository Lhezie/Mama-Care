//
//  OnboardingFlowView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//


//import SwiftUI
//
//struct OnboardingFlowView: View {
//    @EnvironmentObject var viewModel: MamaCareViewModel
//    @StateObject private var onboardingVM = OnboardingViewModel()
//    @State private var currentStep = 0  // Controls the TabView page
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(.systemBackground).ignoresSafeArea()
//
//                TabView(selection: $currentStep) {
//                    ConsentScreenView(currentStep: $currentStep)
//                        .tag(0)
//
//                    UserTypeSelectionView(currentStep: $currentStep)
//                        .tag(1)
//
//                    DateCaptureView(currentStep: $currentStep)
//                        .tag(2)
//
//                    EmergencyContactsView(currentStep: $currentStep)
//                        .tag(3)
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            }
//            .navigationBarHidden(true)
//        }
//        .environmentObject(onboardingVM)
//    }
//}


//import SwiftUI
//
//struct OnboardingFlowView: View {
//    @EnvironmentObject var viewModel: MamaCareViewModel
//    @StateObject private var onboardingVM = OnboardingViewModel()
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(.systemBackground)
//                    .ignoresSafeArea()
//                
//                TabView(selection: $viewModel.currentOnboardingStep) {
//                    ConsentScreenView()
//                        .tag(0)
//                    
//                    UserTypeSelectionView()
//                        .tag(1)
//                    
//                    DateCaptureView()
//                        .tag(2)
//                    
//                    EmergencyContactsView()
//                        .tag(3)
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            }
//            .navigationBarHidden(true)
//        }
//        .environmentObject(onboardingVM)
//    }
//}



//import SwiftUI
//
//struct OnboardingFlowView: View {
//    @EnvironmentObject var viewModel: MamaCareViewModel
//    @StateObject private var onboardingVM = OnboardingViewModel()
//
//    @State private var step: OnboardingStep = .personalInfo
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(.systemBackground).ignoresSafeArea()
//
//                Group {
//                    switch step {
//                    case .personalInfo:
//                        CreateAccountStepOneView(
//                            onNext: handlePersonalInfo
//                        )
//
//                    case .accountInfo:
//                        CreateAccountStepTwoView(
//                            onNext: handleAccountInfo,
//                            onBack: goBack
//                        )
//
//                    case .consent:
//                        ConsentScreenView(
//                            onNext: handleConsent,
//                            onBack: goBack
//                        )
//
//                    case .userType:
//                        UserTypeSelectionView(
//                            onNext: handleUserType,
//                            onBack: goBack
//                        )
//
//                    case .dateCapture:
//                        DateCaptureView(
//                            onNext: handleDateCapture,
//                            onBack: goBack
//                        )
//
//                    case .emergencyContacts:
//                        EmergencyContactsView(
//                            onFinish: completeOnboarding,
//                            onBack: goBack
//                        )
//                    }
//                }
//                .environmentObject(viewModel)
//                .environmentObject(onboardingVM)
//            }
//        }
//    }
//
//    // MARK: - Navigation Handlers
//
//    private func handlePersonalInfo() {
//        if onboardingVM.isPersonalInfoValid {
//            step = .accountInfo
//        } else {
//            onboardingVM.showPersonalInfoError = true
//        }
//    }
//
//    private func handleAccountInfo() {
//        if onboardingVM.isAccountInfoValid {
//            step = .consent
//        } else {
//            onboardingVM.showAccountInfoError = true
//        }
//    }
//
//    private func handleConsent() {
//        if onboardingVM.canCompleteAccount {
//            onboardingVM.user.privacyAcceptedAt = Date()
//            step = .userType
//        } else {
//            onboardingVM.showConsentError = true
//        }
//    }
//
//    private func handleUserType() {
//        if onboardingVM.user.userType != nil {
//            step = .dateCapture
//        }
//    }
//
//    private func handleDateCapture() {
//        if onboardingVM.isDateValid {
//            step = .emergencyContacts
//        } else {
//            onboardingVM.showDateError = true
//        }
//    }
//
//    private func completeOnboarding() {
//        viewModel.completeOnboarding(
//            with: onboardingVM.user,
//            storage: onboardingVM.storageOption,
//            wantsReminders: onboardingVM.wantsReminders
//        )
//    }
//
//    private func goBack() {
//        switch step {
//        case .accountInfo:
//            step = .personalInfo
//        case .consent:
//            step = .accountInfo
//        case .userType:
//            step = .consent
//        case .dateCapture:
//            step = .userType
//        case .emergencyContacts:
//            step = .dateCapture
//        default:
//            break
//        }
//    }
//}
//
//enum OnboardingStep {
//    case personalInfo, accountInfo, consent, userType, dateCapture, emergencyContacts
//}



// OnboardingFlowView.swift
import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()

    @State private var step: OnboardingStep = .personalInfo

    var body: some View {
        NavigationStack {
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
            }
        }
    }

    // MARK: - Navigation Handlers

    private func handlePersonalInfo() {
        if onboardingVM.isPersonalInfoValid {
            step = .accountInfo
        } else {
            onboardingVM.showPersonalInfoError = true
        }
    }

    private func handleAccountInfo() {
        if onboardingVM.isAccountInfoValid {
            step = .consent
        } else {
            onboardingVM.showAccountInfoError = true
        }
    }

    private func handleConsent() {
        print("🔍 OnboardingFlowView - handleConsent called")
        print("   - canCompleteAccount: \(onboardingVM.canCompleteAccount)")
        
        if onboardingVM.canCompleteAccount {
            print("✅ handleConsent - validation passed, setting privacyAcceptedAt and navigating to userType")
            onboardingVM.user.privacyAcceptedAt = Date()
            step = .userType
        } else {
            print("❌ handleConsent - validation failed, showing consent error")
            onboardingVM.showConsentError = true
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
        viewModel.completeOnboarding(
            with: onboardingVM.user,
            storage: onboardingVM.storageOption,
            wantsReminders: onboardingVM.wantsReminders
        )
    }

    private func goBack() {
        switch step {
        case .accountInfo:
            step = .personalInfo
        case .consent:
            step = .accountInfo
        case .userType:
            step = .consent
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





//import SwiftUI
//
//struct OnboardingFlowView: View {
//    @EnvironmentObject var viewModel: MamaCareViewModel
//    @StateObject private var onboardingVM = OnboardingViewModel()
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(.systemBackground).ignoresSafeArea()
//
//                Group {
//                    switch onboardingVM.currentStep {
//                    case .personalInfo:
//                        CreateAccountStepOneView(
//                            onboardingVM: onboardingVM,
//                            onNext: handlePersonalInfo
//                        )
//                    case .accountInfo:
//                        CreateAccountStepTwoView(
//                            onboardingVM: onboardingVM,
//                            onBack: onboardingVM.goBack,
//                            onCreateAccount: handleAccountInfo
//                        )
//                    case .consent:
//                        ConsentScreenView(
//                            onboardingVM: onboardingVM,
//                            onNext: handleConsent,
//                            onBack: onboardingVM.goBack
//                        )
//                    case .userType:
//                        UserTypeSelectionView(
//                            onboardingVM: onboardingVM,
//                            onNext: handleUserType,
//                            onBack: onboardingVM.goBack
//                        )
//                    case .dateCapture:
//                        DateCaptureView(
//                            onboardingVM: onboardingVM,
//                            onNext: handleDateCapture,
//                            onBack: onboardingVM.goBack
//                        )
//                    case .emergencyContacts:
//                        EmergencyContactsView(
//                            onboardingVM: onboardingVM,
//                            onFinish: completeOnboarding,
//                            onBack: onboardingVM.goBack
//                        )
//                    }
//                }
//                .environmentObject(viewModel)
//                .environmentObject(onboardingVM)
//            }
//        }
//    }
//
//    // MARK: - Navigation Handlers
//
//    private func handlePersonalInfo() {
//        if onboardingVM.isPersonalInfoValid {
//            onboardingVM.goToNextStep()
//        } else {
//            onboardingVM.showPersonalInfoError = true
//        }
//    }
//
//    private func handleAccountInfo() {
//        if onboardingVM.isAccountInfoValid {
//            onboardingVM.goToNextStep()
//        } else {
//            onboardingVM.showAccountInfoError = true
//        }
//    }
//
//    private func handleConsent() {
//        if onboardingVM.canCompleteAccount {
//            onboardingVM.user.privacyAcceptedAt = Date()
//            onboardingVM.goToNextStep()
//        } else {
//            onboardingVM.showConsentError = true
//        }
//    }
//
//    private func handleUserType() {
//        if onboardingVM.user.userType != nil {
//            onboardingVM.goToNextStep()
//        }
//    }
//
//    private func handleDateCapture() {
//        if onboardingVM.isDateValid {
//            onboardingVM.goToNextStep()
//        } else {
//            onboardingVM.showDateError = true
//        }
//    }
//
//    private func completeOnboarding() {
//        viewModel.completeOnboarding(
//            with: onboardingVM.user,
//            storage: onboardingVM.storageOption,
//            wantsReminders: onboardingVM.wantsReminders
//        )
//    }
//}
//
//enum OnboardingStep: CaseIterable {
//    case personalInfo, accountInfo, consent, userType, dateCapture, emergencyContacts
//}
//
//class OnboardingViewModel: ObservableObject {
//    @Published var user = MamaUser()
//    @Published var currentStep: OnboardingStep = .personalInfo
//
//    @Published var showPersonalInfoError = false
//    @Published var showAccountInfoError = false
//    @Published var showConsentError = false
//    @Published var showDateError = false
//
//    @Published var storageOption: StorageOption = .iCloud
//    @Published var wantsReminders: Bool = true
//
//    var isPersonalInfoValid: Bool {
//        !user.name.isEmpty && !user.email.isEmpty
//    }
//
//    var isAccountInfoValid: Bool {
//        !user.password.isEmpty && user.password.count >= 6
//    }
//
//    var canCompleteAccount: Bool {
//        user.privacyAcceptedAt != nil
//    }
//
//    var isDateValid: Bool {
//        user.dueDate != nil
//    }
//
//    func goToNextStep() {
//        if let index = OnboardingStep.allCases.firstIndex(of: currentStep),
//           index + 1 < OnboardingStep.allCases.count {
//            currentStep = OnboardingStep.allCases[index + 1]
//        }
//    }
//
//    func goBack() {
//        if let index = OnboardingStep.allCases.firstIndex(of: currentStep), index > 0 {
//            currentStep = OnboardingStep.allCases[index - 1]
//        }
//    }
//}
//
