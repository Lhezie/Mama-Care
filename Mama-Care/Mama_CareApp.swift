//
//  Mama_CareApp.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI
//
//@main
//struct MamaCareApp: App {
//    @StateObject private var viewModel = MamaCareViewModel()
//    
//    var body: some Scene {
//        WindowGroup {
//            Group {
//                if viewModel.isLoggedIn {
//                    if viewModel.hasCompletedOnboarding {
//                        MainTabView()
//                            .environmentObject(viewModel)
//                    } else {
//                        OnboardingFlowView()
//                            .environmentObject(viewModel)
//                    }
//                } else {
//                    AuthLandingView()
//                        .environmentObject(viewModel)
//                }
//            }
//        }
//    }
//}



//import SwiftUI
//
//@main
//struct MamaCareApp: App {
//    @StateObject private var viewModel = MamaCareViewModel()
//    @State private var showSplash = true
//
//    var body: some Scene {
//        WindowGroup {
//            if showSplash {
//                SplashScreenView {
//                    // Called after splash finishes
//                    showSplash = false
//                }
//            } else {
//                Group {
//                    if viewModel.isLoggedIn {
//                        if viewModel.currentUser?.needsOnboarding ?? true {
//                            MainTabView()
//                                .environmentObject(viewModel)
//                        } else {
//                            MainTabView()
//                                .environmentObject(viewModel)
//                        }
//                    } else {
//                        AuthLandingView()
//                            .environmentObject(viewModel)
//                    }
//                }
//            }
//        }
//    }
//}


import SwiftUI

@main
struct MamaCareApp: App {
    @StateObject private var viewModel = MamaCareViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()   // ✅ Add this
    @State private var showSplash = true

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
    }
}

