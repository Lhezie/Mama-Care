import Foundation

@MainActor
final class NutritionViewModel: ObservableObject {
    @Published var nutritionData: NutritionData?
    @Published var postpartumDays: [PostpartumDay]?
    
    //  JSON Loading
    
    func loadNutritionAndPostpartum() {
        print(" Loading nutrition and postpartum JSON data...")
        
        // Load nutrition data
        nutritionData = JSONDataLoader.loadNutritionData()
        
        // Load postpartum data
        postpartumDays = JSONDataLoader.loadPostpartumData()
        
        if let days = postpartumDays {
            print(" Loaded \(days.count) postpartum days in NutritionViewModel")
        } else {
            print(" Failed to load postpartum days in NutritionViewModel")
        }
    }
    
    func reloadPostpartumData() {
        print(" Manually reloading postpartum data in NutritionViewModel...")
        postpartumDays = JSONDataLoader.loadPostpartumData()
        
        if let days = postpartumDays {
            print(" Reloaded \(days.count) postpartum days")
        } else {
            print(" Failed to reload postpartum days")
        }
    }
    
    //  Pregnancy Nutrition Helpers
    
    func getCurrentWeekNutrition(for user: User?) -> NutritionWeek? {
        guard let user = user,
              let nutritionData = nutritionData else {
            print(" No user or nutrition data")
            return nil
        }
        
        let pregnancyWeek = user.pregnancyWeek
        guard pregnancyWeek > 0 else {
            print(" Invalid pregnancy week: \(pregnancyWeek)")
            return nil
        }
        
        // Try to find the exact week
        if let weekData = nutritionData.weeks.first(where: { $0.week == pregnancyWeek }) {
            print(" Found nutrition data for week \(pregnancyWeek)")
            return weekData
        }
        
        // Fallback: Use Week 1 data if specific week not found
        print(" Week \(pregnancyWeek) not found in nutrition data, using Week 1 as fallback")
        return nutritionData.weeks.first
    }
    
    func getCurrentDayNutrition(for user: User?) -> NutritionDay? {
        guard let weekData = getCurrentWeekNutrition(for: user) else {
            return nil
        }
        
        let dayOfWeek = MamaCareDateHelper.mondayBasedWeekday()
        return weekData.days.first { $0.day == dayOfWeek }
    }
    
    //  Postpartum Helpers
    
    func getPostpartumTip(for daysPostpartum: Int) -> PostpartumDay? {
        guard let postpartumDays = postpartumDays else {
            print(" No postpartum data loaded - postpartumDays is nil")
            return nil
        }
        
        print(" Postpartum data loaded: \(postpartumDays.count) days available")
        print(" Looking for tip for day \(daysPostpartum)")
        
        // Debug: Print first few day numbers
        let firstFewDays = postpartumDays.prefix(10).map { $0.dayNumber }
        print("   First 10 day numbers: \(firstFewDays)")
        
        // Try to find exact day match
        if let exactMatch = postpartumDays.first(where: { $0.dayNumber == daysPostpartum }) {
            print(" Found exact postpartum tip for day \(daysPostpartum)")
            print("   Title: \(exactMatch.title)")
            print("   Messages count: \(exactMatch.messages.count)")
            return exactMatch
        }
        
        // If no exact match, find the closest day that's less than or equal to current day
        let closestDay = postpartumDays
            .filter { $0.dayNumber <= daysPostpartum }
            .max(by: { $0.dayNumber < $1.dayNumber })
        
        if let closest = closestDay {
            print(" No exact match for day \(daysPostpartum), using day \(closest.dayNumber) instead")
            print("   Title: \(closest.title)")
            print("   Messages count: \(closest.messages.count)")
            return closest
        }
        
        print(" No postpartum tip found for day \(daysPostpartum)")
        return nil
    }
}
