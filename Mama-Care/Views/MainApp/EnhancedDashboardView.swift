//
//  EnhancedDashboardView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI

struct EnhancedDashboardView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
  
    @Binding var selectedTab: Int
    @State private var showCalmingAudio = false
    @State private var showPremiumAlert = false
    @State private var showSubscriptionSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Offline Indicator Banner
                    if viewModel.isOffline {
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text("Offline - using last synced data")
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.mamaCareOrange)
                        .foregroundColor(.white)
                        .transition(.move(edge: .top))
                    }
                    
                    // Header with Gradient Background
                    headerSection 
                    
                    VStack(spacing: 24) {
                        // Progress Card (Overlapping Header)
                        if viewModel.currentUser?.userType == .pregnant {
                            pregnancyProgressSection
                                .offset(y: -40)
                                .padding(.bottom, -40)
                        } else if viewModel.currentUser?.userType == .hasChild {
                            postpartumProgressSection
                                .offset(y: -40)
                                .padding(.bottom, -40)
                        }
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Mood Trend Chart
                        moodTrendSection
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
                    Text("Week \(viewModel.currentUser?.pregnancyWeek ?? 0) of 40")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
//                    
//                    Text("Your baby is the size of a a")
//                        .font(.system(size: 16))
//                        .foregroundColor(.white.opacity(0.9))
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
                    Text("\(viewModel.pregnancyProgressPercentage)%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.mamaCareDarkGreen)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(viewModel.calculateProgress()), height: 8)
                            .foregroundColor(.mamaCareDarkGreen)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("Approximately \(viewModel.weeksRemaining) weeks to go")
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
    
    private var postpartumProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let days = viewModel.calculateDaysPostpartum() ?? 0
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day \(days)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Days with your little one")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "figure.and.child")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Spacer().frame(height: 20)
            
            Text("Remember to take care of yourself too, mama.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
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
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
                
                Spacer()
                
                Button(action: { showCalmingAudio = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                        Text("Calming")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.mamaCarePrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.mamaCarePrimaryLight)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            if let times = viewModel.currentUser?.checkInTimes, !times.isEmpty {
                let formattedTimes = times.sorted().map { minutes -> String in
                    let hour = minutes / 60
                    let minute = minutes % 60
                    return String(format: "%02d:%02d", hour, minute)
                }.joined(separator: ", ")
                
                Text("You have set \(times.count) daily reminders (\(formattedTimes)) for mood check-ins")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                Text("You'll receive 3 daily reminders (08:00, 14:00, 20:00) for mood check-ins")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
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
                    if viewModel.isPremium {
                        selectedTab = 4
                    } else {
                        showPremiumAlert = true
                    }
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
        .sheet(isPresented: $showCalmingAudio) {
            CalmingAudioView()
                .environmentObject(viewModel)
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
    
    private var moodTrendSection: some View {
        MoodTrendChartView(moodCheckIns: viewModel.moodCheckIns)
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

//  Preview
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
