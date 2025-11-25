//
//  Mama_CareApp.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct MamaCareApp: App {
    @StateObject private var viewModel = MamaCareViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()   // ✅ Add this
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
                .environmentObject(viewModel)
                .environmentObject(onboardingVM)   // ✅ Inject here too
            } else {
                Group {
                    if viewModel.isLoggedIn {
                        if viewModel.currentUser?.needsOnboarding ?? true {
                            MainTabView()
                                .environmentObject(viewModel)
                                .environmentObject(onboardingVM)   // ✅ Add here
                        } else {
                            MainTabView()
                                .environmentObject(viewModel)
                                .environmentObject(onboardingVM)   // ✅ Add here
                        }
                    } else {
                        AuthLandingView()
                            .environmentObject(viewModel)
                            .environmentObject(onboardingVM)       // ✅ Add here
                    }
                }
            }
        }
        .modelContainer(for: [UserProfile.self, MoodEntry.self, Contact.self])
    }
}

