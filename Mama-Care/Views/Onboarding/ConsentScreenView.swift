//
//  ConsentView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 04/11/2025.
//

//



//



//import SwiftUI
//
//struct ConsentScreenView: View {
//    @State private var showValidationError = false
//    @State private var goToUserTypeSelection = false
//
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var viewModel: MamaCareViewModel
//    @EnvironmentObject var onboardingVM: OnboardingViewModel
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                LinearGradient(
//                    colors: [Color(hex: "F3F3F5"), .mamaCareGrayLight],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: 24) {
//                        headerSection
//
//                        // Storage cards
//                        VStack(spacing: 20) {
//                            storageCard(
//                                option: .device,
//                                icon: "iphone",
//                                iconColor: Color(hex: "D0E8FF"),
//                                title: "Device-Only Storage",
//                                points: [
//                                    ConsentPoint(color: .green, text: "Highest privacy - data never leaves device"),
//                                    ConsentPoint(color: .green, text: "No internet required"),
//                                    ConsentPoint(color: .red, text: "Data lost if device is lost")
//                                ]
//                            )
//
//                            storageCard(
//                                option: .icloud,
//                                icon: "icloud",
//                                iconColor: Color(hex: "F3E8FF"),
//                                title: "iCloud Sync",
//                                points: [
//                                    ConsentPoint(color: .green, text: "Access from multiple devices"),
//                                    ConsentPoint(color: .green, text: "Automatic backup"),
//                                    ConsentPoint(color: .green, text: "Still encrypted end-to-end")
//                                ]
//                            )
//                        }
//
//                        consentSection
//
//                        if showValidationError {
//                            Text("Please select a storage option and accept all required consents.")
//                                .font(.system(size: 14))
//                                .foregroundColor(.red)
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//
//                        HStack(spacing: 16) {
//                            Button("Back") {
//                                dismiss()
//                            }
//                            .buttonStyle(SecondaryButtonStyle())
//
//                            Button("Continue") {
//                                validateAndContinue()
//                            }
//                            .buttonStyle(PrimaryButtonStyle())
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            .navigationDestination(isPresented: $goToUserTypeSelection) {
//                UserTypeSelectionView()
//                    .environmentObject(viewModel)
//                    .environmentObject(onboardingVM)
//            }
//        }
//    }
//
//    private var headerSection: some View {
//        VStack(spacing: 10) {
//            Image(systemName: "shield.fill")
//                .font(.system(size: 40))
//                .foregroundColor(.white)
//                .padding(16)
//                .background(Color.mamaCarePrimary)
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//
//            Text("Privacy & Data Storage")
//                .font(.system(size: 20, weight: .semibold))
//                .foregroundColor(.black)
//
//            Text("Choose how your data is stored and review our privacy practices")
//                .font(.system(size: 15))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//        }
//        .padding(.top, 24)
//    }
//
//    private var consentSection: some View {
//        VStack(alignment: .leading, spacing: 18) {
//            Text("Required Consents")
//                .font(.system(size: 17, weight: .semibold))
//
//            Toggle(isOn: $onboardingVM.acceptedTerms) {
//                HStack(spacing: 0) {
//                    Text("I accept the ")
//                    Text("Terms & Conditions")
//                        .underline()
//                        .foregroundColor(Color.mamaCarePrimary)
//                        .onTapGesture { openLink("https://yourdomain.com/terms") }
//                    Text(" *").foregroundColor(.red)
//                }
//                .font(.system(size: 15))
//            }
//            .toggleStyle(MamaCheckboxToggleStyle())
//
//            Toggle(isOn: $onboardingVM.acceptedPrivacy) {
//                HStack(spacing: 0) {
//                    Text("I have read and agree to the ")
//                    Text("Privacy Policy")
//                        .underline()
//                        .foregroundColor(Color.mamaCarePrimary)
//                        .onTapGesture { openLink("https://yourdomain.com/privacy") }
//                    Text(" *").foregroundColor(.red)
//                }
//                .font(.system(size: 15))
//            }
//            .toggleStyle(MamaCheckboxToggleStyle())
//
//            Toggle(isOn: $onboardingVM.wantsReminders) {
//                Text("I want to receive daily mood check-in reminders (optional)")
//                    .font(.system(size: 15))
//            }
//            .toggleStyle(MamaCheckboxToggleStyle())
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .padding(.horizontal)
//    }
//
//    func storageCard(option: StorageOption,
//                     icon: String,
//                     iconColor: Color,
//                     title: String,
//                     points: [ConsentPoint]) -> some View {
//
//        let isSelected = onboardingVM.storageOption == option
//
//        return VStack(alignment: .leading, spacing: 14) {
//            HStack {
//                Image(systemName: icon)
//                    .font(.system(size: 22))
//                    .foregroundColor(.blue)
//                    .padding(12)
//                    .background(iconColor)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                Spacer()
//
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .font(.system(size: 22))
//                    .foregroundColor(isSelected ? Color.mamaCarePrimary : Color.gray.opacity(0.4))
//            }
//
//            Text(title)
//                .font(.system(size: 17, weight: .semibold))
//                .foregroundColor(.black)
//
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(points) { point in
//                    HStack(alignment: .top, spacing: 8) {
//                        Image(systemName: point.color == .red
//                              ? "exclamationmark.circle"
//                              : "checkmark.circle")
//                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .green)
//
//                        Text(point.text)
//                            .font(.system(size: 15))
//                    }
//                }
//            }
//
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(isSelected ? Color.mamaCarePrimary : .clear, lineWidth: 2)
//        )
//        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        .padding(.horizontal)
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                onboardingVM.storageOption = option
//            }
//        }
//    }
//
//    func validateAndContinue() {
//        if onboardingVM.acceptedTerms && onboardingVM.acceptedPrivacy {
//            // ✅ Update permanent user model in viewModel
//            viewModel.currentUser?.storageMode = onboardingVM.storageOption
//            viewModel.currentUser?.notificationsWanted = onboardingVM.wantsReminders
//            viewModel.currentUser?.privacyAcceptedAt = Date()
//
//            showValidationError = false
//            goToUserTypeSelection = true
//        } else {
//            showValidationError = true
//        }
//    }
//
//    func openLink(_ urlString: String) {
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url)
//        }
//    }
//}


import SwiftUI

struct ConsentScreenView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showValidationError = false

    var body: some View {
        ZStack {
            Color.mamaCarePrimaryBg.ignoresSafeArea()

            LinearGradient(
                colors: [Color(hex: "F3F3F5"), .mamaCareGrayLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.mamaCarePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        Text("Privacy & Data Storage")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)

                        Text("Choose how your data is stored and review our privacy practices")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 24)

                    // Storage Options
                    VStack(spacing: 20) {
                        storageCard(option: .deviceOnly, icon: "iphone", iconColor: Color(hex: "D0E8FF"), title: "Device-Only Storage", points: [
                            ConsentPoint(color: .green, text: "Highest privacy - data never leaves device"),
                            ConsentPoint(color: .green, text: "No internet required"),
                            ConsentPoint(color: .red, text: "Data lost if device is lost")
                        ])

                        storageCard(option: .iCloudSync, icon: "icloud", iconColor: Color(hex: "F3E8FF"), title: "iCloud Sync", points: [
                            ConsentPoint(color: .green, text: "Access from multiple devices"),
                            ConsentPoint(color: .green, text: "Automatic backup"),
                            ConsentPoint(color: .green, text: "Still encrypted end-to-end")
                        ])
                    }

                    // Consents
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Required Consents")
                            .font(.system(size: 17, weight: .semibold))

                        Toggle(isOn: $onboardingVM.acceptedTerms) {
                            HStack(spacing: 0) {
                                Text("I accept the ")
                                Text("Terms & Conditions")
                                    .underline()
                                    .foregroundColor(.mamaCarePrimary)
                                    .onTapGesture { openLink("https://yourdomain.com/terms") }
                                Text(" *").foregroundColor(.red)
                            }
                        }
                        .toggleStyle(MamaCheckboxToggleStyle())

                        Toggle(isOn: $onboardingVM.acceptedPrivacy) {
                            HStack(spacing: 0) {
                                Text("I have read and agree to the ")
                                Text("Privacy Policy")
                                    .underline()
                                    .foregroundColor(.mamaCarePrimary)
                                    .onTapGesture { openLink("https://yourdomain.com/privacy") }
                                Text(" *").foregroundColor(.red)
                            }
                        }
                        .toggleStyle(MamaCheckboxToggleStyle())

                        Toggle(isOn: $onboardingVM.wantsReminders) {
                            Text("I want to receive daily mood check-in reminders (optional)")
                        }
                        .toggleStyle(MamaCheckboxToggleStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Error Message
                    if showValidationError {
                        Text("Please select a storage option and accept all required consents.")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Buttons
                    HStack(spacing: 16) {
                        Button("Back") {
                            onBack()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Continue") {
                            validateAndContinue()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func storageCard(option: StorageMode, icon: String, iconColor: Color, title: String, points: [ConsentPoint]) -> some View {
        let isSelected = onboardingVM.storageOption == option

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .mamaCarePrimary : Color.gray.opacity(0.4))
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(points) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: point.color == .red ? "exclamationmark.circle" : "checkmark.circle")
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .green)
                            .font(.system(size: 16))

                        Text(point.text)
                            .font(.system(size: 15))
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .black)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.mamaCarePrimary : .clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onboardingVM.storageOption = option
            }
        }
    }

    
    private func validateAndContinue() {
        // Debug logging
        print("🔍 ConsentScreenView - validateAndContinue called")
        print("   - storageOption: \(String(describing: onboardingVM.storageOption))")
        print("   - acceptedTerms: \(onboardingVM.acceptedTerms)")
        print("   - acceptedPrivacy: \(onboardingVM.acceptedPrivacy)")
        print("   - canCompleteAccount: \(onboardingVM.canCompleteAccount)")
        
        // Use the ViewModel's validation method
        if onboardingVM.canCompleteAccount {
            print("✅ Validation passed - calling onNext()")
            showValidationError = false
            onNext()
        } else {
            print("❌ Validation failed - showing error")
            showValidationError = true
        }
    }

    private func openLink(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

//import SwiftUI
//
//struct ConsentScreenView: View {
//   
//    
//    @ObservedObject var onboardingVM: OnboardingViewModel
//        var onNext: () -> Void
//        var onBack: () -> Void
//
//    @State private var showValidationError = false
//
//    var body: some View {
//        ZStack {
//            Color.mamaCarePrimaryBg.ignoresSafeArea()
//
//            LinearGradient(
//                colors: [Color(hex: "F3F3F5"), .mamaCareGrayLight],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Header
//                    VStack(spacing: 10) {
//                        Image(systemName: "shield.fill")
//                            .font(.system(size: 40))
//                            .foregroundColor(.white)
//                            .padding(16)
//                            .background(Color.mamaCarePrimary)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//
//                        Text("Privacy & Data Storage")
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(.black)
//
//                        Text("Choose how your data is stored and review our privacy practices")
//                            .font(.system(size: 15))
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                    }
//                    .padding(.top, 24)
//
//                    // Storage Options
//                    VStack(spacing: 20) {
//                        StorageCard(
//                            option: .deviceOnly,
//                            icon: "iphone",
//                            iconColor: Color(hex: "D0E8FF"),
//                            title: "Device-Only Storage",
//                            points: [
//                                ConsentPoint(color: .green, text: "Highest privacy - data never leaves device"),
//                                ConsentPoint(color: .green, text: "No internet required"),
//                                ConsentPoint(color: .red, text: "Data lost if device is lost")
//                            ],
//                            isSelected: onboardingVM.storageOption == .deviceOnly,
//                            onSelect: {
//                                onboardingVM.storageOption = .deviceOnly
//                            }
//                        )
//
//                        StorageCard(
//                            option: .iCloudSync,
//                            icon: "icloud",
//                            iconColor: Color(hex: "F3E8FF"),
//                            title: "iCloud Sync",
//                            points: [
//                                ConsentPoint(color: .green, text: "Access from multiple devices"),
//                                ConsentPoint(color: .green, text: "Automatic backup"),
//                                ConsentPoint(color: .green, text: "Still encrypted end-to-end")
//                            ],
//                            isSelected: onboardingVM.storageOption == .iCloudSync,
//                            onSelect: {
//                                onboardingVM.storageOption = .iCloudSync
//                            }
//                        )
//                    }
//
//                    // Consent Toggles
//                    VStack(alignment: .leading, spacing: 18) {
//                        Text("Required Consents")
//                            .font(.system(size: 17, weight: .semibold))
//
//                        Toggle(isOn: $onboardingVM.acceptedTerms) {
//                            consentText(
//                                leading: "I accept the ",
//                                link: "Terms & Conditions",
//                                url: "https://yourdomain.com/terms"
//                            )
//                        }
//                        .toggleStyle(MamaCheckboxToggleStyle())
//
//                        Toggle(isOn: $onboardingVM.acceptedPrivacy) {
//                            consentText(
//                                leading: "I have read and agree to the ",
//                                link: "Privacy Policy",
//                                url: "https://yourdomain.com/privacy"
//                            )
//                        }
//                        .toggleStyle(MamaCheckboxToggleStyle())
//
//                        Toggle(isOn: $onboardingVM.wantsReminders) {
//                            Text("I want to receive daily mood check-in reminders (optional)")
//                                .font(.system(size: 15))
//                                .foregroundColor(.black)
//                        }
//                        .toggleStyle(MamaCheckboxToggleStyle())
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(20)
//                    .padding(.horizontal)
//
//                    if showValidationError {
//                        Text("Please select a storage option and accept all required consents.")
//                            .font(.system(size: 14))
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                    }
//
//                    // Navigation Buttons
//                    HStack(spacing: 16) {
//                        Button("Back", action: onBack)
//                            .buttonStyle(SecondaryButtonStyle())
//
//                        Button("Continue") {
//                            if onboardingVM.validateConsent() {
//                                showValidationError = false
//                                onNext()
//                            } else {
//                                showValidationError = true
//                            }
//                        }
//                        .buttonStyle(PrimaryButtonStyle())
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//
//    @ViewBuilder
//    private func consentText(leading: String, link: String, url: String) -> some View {
//        HStack(spacing: 0) {
//            Text(leading)
//            Text(link)
//                .underline()
//                .foregroundColor(.mamaCarePrimary)
//                .onTapGesture {
//                    onboardingVM.openLink(url)
//                }
//            Text(" *")
//                .foregroundColor(.red)
//        }
//        .font(.system(size: 15))
//        .foregroundColor(.black)
//    }
//}
//
////struct ConsentScreenView_Previews: PreviewProvider {
////    static var previews: some View {
////        ConsentScreenView(
////            onboardingVM: OnboardingViewModel(),
////            onNext: { },
////            onBack: { }
////        )
////    }
////}
