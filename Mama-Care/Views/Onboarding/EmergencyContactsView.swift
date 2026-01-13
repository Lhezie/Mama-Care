//
//  EmergencyContactsView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 15/11/2025.
//

import SwiftUI

struct EmergencyContactsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    var onFinish: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {


            //  Emergency Contacts Section
            EmergencyContactsSection(showHeader: true)
                .padding(.bottom, 20)

            Spacer()

            //  Navigation
            Button {
                onboardingVM.user.emergencyContacts = viewModel.emergencyContacts
                onFinish()
            } label: {
                HStack {
                    Text("Navigate to Dashboard")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mamaCarePrimary)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "F0FDFA").ignoresSafeArea()) // Light mint background
    }
}
