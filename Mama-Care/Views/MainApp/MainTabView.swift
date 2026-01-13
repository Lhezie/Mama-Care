//
//  MainTabView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedTab: Int = 0 // Added for TabView selection
    @State private var lastSelectedTab: Int = 0
    @State private var showPremiumAlert = false
    @State private var showSubscriptionSheet = false

    var body: some View {
        TabView(selection: $selectedTab) { // Added selection binding
            EnhancedDashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill") // Changed to Label
                }
                .tag(0) // Added tag
            
            MoodCheckInView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Mood", systemImage: "heart.fill") // Changed to Label
                }
                .tag(1) // Added tag
            
            // Show different tabs based on user type
            if viewModel.currentUser?.userType == .pregnant {
                NutritionView()
                    .tabItem {
                        Image(systemName: "leaf.fill")
                        Text("Nutrition")
                    }
                    .tag(2)
            } else {
                PostpartumCareTipView()
                    .tabItem {
                        Image(systemName: "person.2.wave.2.fill")
                        Text("Post Care")
                    }
                    .tag(2)
            }
            
            VaccineScheduleView()
                .tabItem {
                    Label("Vaccines", systemImage: "cross.case.fill")
                }
                .tag(3)
            
            EmergencyView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Emergency")
                }
                .tag(4)
            
            AIChatView(isPresented: .constant(true))
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("AI Chat")
                }
                .tag(5)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(6)
        }
        .accentColor(.purple)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToMood)) { _ in
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVaccines)) { _ in
            selectedTab = 3
        }
        .fullScreenCover(isPresented: $viewModel.showEmergencyEscalation) {
            EmergencyView()
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == 4 { // Emergency Tab
                if !viewModel.isPremium {
                    // Revert to last tab
                    // We need a slight delay or just immediate set back? Immediate usually works or dispatch async.
                    // But we don't have 'oldValue' easily in SwiftUI < 17 without tracking.
                    // Simplest tracking:
                    selectedTab = lastSelectedTab
                    showPremiumAlert = true
                } else {
                    lastSelectedTab = newTab
                }
            } else {
                lastSelectedTab = newTab
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            PaywallView()
                .environmentObject(viewModel)
        }
        .alert("Premium Feature", isPresented: $showPremiumAlert) {
            Button("Subscribe", role: .none) {
                showSubscriptionSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The Emergency Escalation feature requires a premium subscription. Please subscribe to access this safety tool.")
        }
    }
}

//  Preview
#Preview("Pregnant User") {
    MainTabView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Sarah",
                lastName: "Johnson",
                email: "sarah@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .pregnant,
                expectedDeliveryDate: Calendar.current.date(byAdding: .weekOfYear, value: 25, to: Date())
            )
            return viewModel
        }())
}

#Preview("Postpartum User") {
    MainTabView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Emma",
                lastName: "Wilson",
                email: "emma@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .hasChild,
                birthDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())
            )
            return viewModel
        }())
}
