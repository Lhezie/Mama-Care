//
//  PostpartumCareTipView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct PostpartumCareTipView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var isPaused = false
    @State private var currentMessageIndex = 0
    
    var daysPostpartum: Int? {
        viewModel.calculateDaysPostpartum()
    }
    
    var postpartumTip: PostpartumDay? {
        guard let days = daysPostpartum else { return nil }
        return viewModel.getPostpartumTip(daysPostpartum: days)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            headerSection
            
            // Days postpartum badge
            if let days = daysPostpartum {
                postpartumBadge(days: days)
                    .padding(.top, 24)
            }
            
            // Gradient progress bar
            gradientProgressBar
                .padding(.top, 20)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Main content card
            tipContentSection
            
            Spacer()
        }
        .background(Color.mamaCareGrayLight)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // Reload postpartum data when view appears to ensure it's loaded
            print("🔍 PostpartumCareTipView appeared")
            print("   Days postpartum: \(daysPostpartum?.description ?? "nil")")
            print("   Current user type: \(viewModel.currentUser?.userType?.rawValue ?? "nil")")
            print("   Birth date: \(viewModel.currentUser?.birthDate?.description ?? "nil")")
            
            // Reload data if not already loaded
            if viewModel.postpartumDays == nil {
                print("⚠️ Postpartum data is nil, attempting to reload...")
                viewModel.reloadPostpartumData()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.mamaCarePrimary, Color.mamaCarePrimary.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // MamaCare logo
                    ZStack {
                        Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        
                        Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.mamaCarePrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MamaCare")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        
                        Text("Welcome, \(viewModel.currentUser?.firstName ?? " ")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 120)
    }
    
    // MARK: - Postpartum Badge
    private func postpartumBadge(days: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundColor(.mamaCarePink)
            
            VStack(spacing: 2) {
                Text("\(days) days")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.mamaCarePink)
                
                Text("postpartum")
                    .font(.system(size: 12))
                    .foregroundColor(.mamaCarePink)
            }
        }
    }
    
    // MARK: - Gradient Progress Bar
    private var gradientProgressBar: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.mamaCarePrimary,
                        Color.mamaCareUpcoming,
                        Color.mamaCarePurple
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 8)
    }
    
    // MARK: - Tip Content Section
    @ViewBuilder
    private var tipContentSection: some View {
        if let tip = postpartumTip, !tip.messages.isEmpty {
            VStack(spacing: 32) {
                // Pause/Play button
                pauseButton
                
                // Tip message
                Text(tip.messages[currentMessageIndex])
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.mamaCareTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Dot indicators
                if tip.messages.count > 1 {
                    dotsIndicator(tip: tip)
                }
            }
            .padding(.vertical, 48)
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
        } else {
            emptyStateView
        }
    }
    
    // MARK: - Quote Icon
    private var pauseButton: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.mamaCareUpcoming,
                            Color.mamaCarePurple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .shadow(color: Color.mamaCareUpcoming.opacity(0.4), radius: 12, x: 0, y: 6)
            
            Image(systemName: "quote.opening")
                .font(.system(size: 28))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Dots Indicator
    private func dotsIndicator(tip: PostpartumDay) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<tip.messages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentMessageIndex ? Color.mamaCarePink : Color.mamaCareGrayBorder)
                    .frame(width: 8, height: 8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentMessageIndex = index
                        }
                    }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.mamaCarePink.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No tips available")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.mamaCareTextPrimary)
                
                Text("Please set your baby's birth date in settings to see postpartum care tips")
                    .font(.system(size: 15))
                    .foregroundColor(.mamaCareTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 32)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview
#Preview {
    PostpartumCareTipView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            // Set up sample user with child
            viewModel.currentUser = User(
                firstName: "Skoda",
                lastName: "Johnson",
                email: "skoda@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .hasChild,
                birthDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())
            )
            return viewModel
        }())
}
