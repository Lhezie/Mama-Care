//
//  EnhancedDashboardView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct EnhancedDashboardView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
  
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with Gradient Background
                    headerSection
                    
                    VStack(spacing: 24) {
                        // Pregnancy Progress Card (Overlapping Header)
                        pregnancyProgressSection
                            .offset(y: -40)
                            .padding(.bottom, -40)
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Postpartum Tips (Optional, keeping as per previous code but maybe simplified)
                        // postpartumTipsSection
                        
                        // Nutrition Plan (Optional, keeping as per previous code)
                        // nutritionPlanSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .background(Color.mamaCareGrayLight) // Light gray background for the whole view
        }
    }

    
    private var headerSection: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180) // Adjust height as needed
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                        
                        Text("MamaCare")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("Welcome,\( viewModel.currentUser?.firstName ?? " ")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                
            }
            .padding(.horizontal)
            .padding(.top, 60) // Adjust for safe area
            .padding(.bottom, 60)
        }
    }
    
    private var pregnancyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week 15 of 40")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your baby is the size of a apple")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "heart")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Spacer().frame(height: 20)
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to delivery")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("38%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.mamaCareDarkGreen) // Darker green background
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * 0.38, height: 8)
                            .foregroundColor(.mamaCareDarkGreen) // Dark progress color
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("Approximately 25 weeks to go")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.mamaCareTeal, .mamaCareTealDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.mamaCareTextPrimary)
                .padding(.horizontal)
            
            Text("You'll receive 3 daily reminders (08:00, 14:00, 20:00) for mood check-ins")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                DashboardActionButton(
                    title: "Mood Check-In",
                    icon: "heart",
                    color: .mamaCareMagenta,
                    bgColor: .mamaCarePurpleLight
                ) {
                    selectedTab = 1 // Navigate to Mood tab
                }
                
                DashboardActionButton(
                    title: "Vaccines",
                    icon: "shield",
                    color: .mamaCareMagenta,
                    bgColor: .mamaCarePurpleLight
                ) {
                    selectedTab = 3 // Navigate to Vaccines tab
                }
                
                DashboardActionButton(
                    title: "Emergency",
                    icon: "phone",
                    color: .mamaCareOverdue,
                    bgColor: .mamaCareRedLight
                ) {
                    selectedTab = 4 // Navigate to Emergency tab
                }
                
                DashboardActionButton(
                    title: "AI Chat",
                    icon: "bubble.left",
                    color: .mamaCareOrange,
                    bgColor: .mamaCareOrangeLight
                ) {
                    selectedTab = 5 // Navigate to AI Chat tab
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DashboardActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let bgColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "374151"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    EnhancedDashboardView(selectedTab: .constant(0))
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Elizabeth",
                lastName: "Smith",
                email: "elizabeth@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .pregnant,
                expectedDeliveryDate: Calendar.current.date(byAdding: .weekOfYear, value: 25, to: Date())
            )
            return viewModel
        }())
}
