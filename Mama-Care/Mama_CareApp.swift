//
//  Mama_CareApp.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct MamaCareApp: App {
    @StateObject private var viewModel = MamaCareViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()   
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, onboardingVM: onboardingVM, showSplash: $showSplash)
                .preferredColorScheme(.light)
                .modelContainer(for: [UserProfile.self, MoodEntry.self, Contact.self, VaccineRecord.self])
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: MamaCareViewModel
    @ObservedObject var onboardingVM: OnboardingViewModel
    @Binding var showSplash: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
                .environmentObject(viewModel)
                .environmentObject(onboardingVM)
            } else {
                Group {
                    if viewModel.isLoggedIn {
                        if viewModel.currentUser?.needsOnboarding ?? true {
                            MainTabView()
                                .environmentObject(viewModel)
                                .environmentObject(onboardingVM)
                        } else {
                            MainTabView()
                                .environmentObject(viewModel)
                                .environmentObject(onboardingVM)
                        }
                    } else {
                        AuthLandingView()
                            .environmentObject(viewModel)
                            .environmentObject(onboardingVM)
                    }
                }
            }
        }
        .onAppear {
            // Inject the ModelContext into SwiftDataService when view appears
            SwiftDataService.shared.setModelContext(modelContext)
        }
    }
}

