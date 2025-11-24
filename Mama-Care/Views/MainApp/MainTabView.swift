//
//  MainTabView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedTab: Int = 0 // Added for TabView selection

    var body: some View {
        TabView(selection: $selectedTab) { // Added selection binding
            EnhancedDashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill") // Changed to Label
                }
                .tag(0) // Added tag
            
            MoodCheckInView()
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
            
            AIChatView()
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
    }
}

// MARK: - Preview
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
