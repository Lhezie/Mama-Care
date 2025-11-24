//
//  EmergencyContactsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 15/11/2025.
//

import SwiftUI

struct EmergencyContactsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    var onFinish: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {


            // MARK: - Emergency Contacts Section
            EmergencyContactsSection(showHeader: true)
                .padding(.bottom, 20)

            Spacer()

            // MARK: - Navigation
            HStack(spacing: 16) {
                Button("Skip for Now") {
                    completeOnboarding()
                }
                .font(.headline)
                .foregroundColor(.mamaCareTextPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.mamaCareGrayBorder, lineWidth: 1)
                )

                Button {
                    completeOnboarding()
                } label: {
                    HStack {
                        Text("Skip to Dashboard")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mamaCarePrimary)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "F0FDFA").ignoresSafeArea()) // Light mint background
    }
    
    private func completeOnboarding() {
        onboardingVM.user.emergencyContacts = viewModel.emergencyContacts
        viewModel.completeOnboarding(
            with: onboardingVM.user,
            storage: onboardingVM.storageOption,
            wantsReminders: onboardingVM.wantsReminders
        )
        onFinish()
    }
}
