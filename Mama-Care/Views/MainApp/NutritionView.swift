import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    //  Computed helpers
    
    private var userWeekText: String? {
        guard let user = viewModel.currentUser else { return nil }
        let week = user.pregnancyWeek
        return week > 0 ? "Week \(week)" : nil
    }
    
    private var currentWeekNutrition: NutritionWeek? {
        viewModel.getCurrentWeekNutrition()
    }
    
    private var currentDayNutrition: NutritionDay? {
        viewModel.getCurrentDayNutrition()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                if let weekData = currentWeekNutrition {
                    weekFocusSection(weekData: weekData)
                }
                
                if let dayData = currentDayNutrition {
                    todaysMealSection(dayData: dayData)
                    recommendedFoodsSection(foods: dayData.foodSuggestions)
                    waterIntakeSection(cups: dayData.waterGoalCups)
                } else {
                    Text("Nutrition tips will appear here once your due date is set.")
                        .font(.footnote)
                        .foregroundColor(.mamaCareTextSecondary)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .background(Color.mamaCareGrayLight)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //  Header Section
    
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
            
            if let weekText = userWeekText {
                Text(weekText)
                    .font(.subheadline)
                    .foregroundColor(.mamaCareTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    //  Week Focus Section
    
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
    
    //  Today's Meal Section
    
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
    
    //  Recommended Foods Section
    
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
    
    //  Water Intake Section
    
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

//  Preview
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
