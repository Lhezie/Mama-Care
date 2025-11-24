//
//  NutritionView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 15/11/2025.
//

import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // This Week's Focus
                if let weekData = viewModel.getCurrentWeekNutrition() {
                    weekFocusSection(weekData: weekData)
                }
                
                // Today's Meal Focus
                if let dayData = viewModel.getCurrentDayNutrition() {
                    todaysMealSection(dayData: dayData)
                    
                    // Recommended Foods
                    recommendedFoodsSection(foods: dayData.foodSuggestions)
                    
                    // Water Intake
                    waterIntakeSection(cups: dayData.waterGoalCups)
                }
            }
            .padding()
        }
        .background(Color.mamaCareGrayLight)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding(16)
                .background(Color.mamaCareCompleted)
                .clipShape(Circle())
            
            Text("Daily Nutrition Guide")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.mamaCareTextPrimary)
            
            if let user = viewModel.currentUser {
                let week = user.pregnancyWeek
                if week > 0 {
                    Text("Week \(week)")
                        .font(.subheadline)
                        .foregroundColor(.mamaCareTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Week Focus Section
    
    private func weekFocusSection(weekData: NutritionWeek) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.mamaCareDue)
                Text("This Week's Focus")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
            }
            
            Text(weekData.theme)
                .font(.body)
                .foregroundColor(.mamaCareTextDark)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mamaCareDueBg)
        .cornerRadius(16)
    }
    
    // MARK: - Today's Meal Section
    
    private func todaysMealSection(dayData: NutritionDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.mamaCarePrimary)
                Text("Today's Meal Focus")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
            }
            
            Text(dayData.headline)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.mamaCareTextPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Recommended Foods Section
    
    private func recommendedFoodsSection(foods: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.mamaCarePink)
                Text("Recommended Foods")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
            }
            
            VStack(spacing: 12) {
                ForEach(foods, id: \.self) { food in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.mamaCareCompleted)
                        
                        Text(food)
                            .font(.body)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "F0FDF4"))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Water Intake Section
    
    private func waterIntakeSection(cups: Int) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.mamaCareUpcoming)
                Text("Water Intake Goal")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<cups, id: \.self) { _ in
                    Image(systemName: "drop.fill")
                        .foregroundColor(.mamaCareUpcoming)
                }
            }
            
            Text("\(cups) cups per day")
                .font(.subheadline)
                .foregroundColor(.mamaCareTextSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "EFF6FF"))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    NutritionView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Emma",
                lastName: "Wilson",
                email: "emma@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .pregnant,
                expectedDeliveryDate: Calendar.current.date(byAdding: .weekOfYear, value: 25, to: Date())
            )
            return viewModel
        }())
}
