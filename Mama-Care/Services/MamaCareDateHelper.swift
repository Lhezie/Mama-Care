import Foundation

enum MamaCareDateHelper {
    
    private static var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }
    
    //  Pregnancy
    
    /// Returns the current pregnancy week (1–40) based on EDD and a given "today" date.
    /// Uses the 40-week (280 day) convention.
    static func pregnancyWeek(edd: Date, on date: Date = Date()) -> Int {
        let calendar = Self.calendar
        let today = calendar.startOfDay(for: date)
        let eddDay = calendar.startOfDay(for: edd)
        
        // days_to_edd = EDD - today
        guard let daysToEDD = calendar.dateComponents([.day], from: today, to: eddDay).day else {
            return 0
        }
        
        // GA_days = 280 - days_to_edd
        let gestationDays = 280 - daysToEDD
        
        // If <= 0 → before conception/LMP or too early to count
        if gestationDays <= 0 { return 0 }
        
        let weeksCompleted = gestationDays / 7
        let weekNumber = weeksCompleted + 1 // Week 1–40
        
        return min(max(weekNumber, 1), 40)
    }
    
    /// Returns (weeks, days) of gestational age.
    /// E.g. (30, 6) means 30 weeks + 6 days.
    static func gestationalAge(edd: Date, on date: Date = Date()) -> (weeks: Int, days: Int)? {
        let calendar = Self.calendar
        let today = calendar.startOfDay(for: date)
        let eddDay = calendar.startOfDay(for: edd)
        
        guard let daysToEDD = calendar.dateComponents([.day], from: today, to: eddDay).day else {
            return nil
        }
        
        let gestationDays = 280 - daysToEDD
        if gestationDays <= 0 { return nil }
        
        let weeks = gestationDays / 7
        let days = gestationDays % 7
        return (weeks, days)
    }
    
    //  Postpartum
    
    /// Returns total days postpartum (0+).
    static func daysPostpartum(birthDate: Date, on date: Date = Date()) -> Int {
        let calendar = Self.calendar
        let start = calendar.startOfDay(for: birthDate)
        let today = calendar.startOfDay(for: date)
        
        let diff = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        // Use 1-based indexing: Day of birth is Day 1
        return max(1, diff + 1)
    }
    
    /// Returns postpartum week number (1, 2, 3, ...) from birth date.
    /// Week 1 = days 0–6, Week 2 = days 7–13, etc.
    static func postpartumWeek(birthDate: Date, on date: Date = Date()) -> Int {
        let days = daysPostpartum(birthDate: birthDate, on: date)
        let weeksCompleted = days / 7
        return weeksCompleted + 1
    }
    
    //  Weekday helper for nutrition
    
    /// Returns day of week in Monday=1 ... Sunday=7 format.
    static func mondayBasedWeekday(for date: Date = Date()) -> Int {
        let calendar = Self.calendar
        let weekday = calendar.component(.weekday, from: date) // Sunday=1...Saturday=7
        
        // Convert to Monday=1...Sunday=7
        return (weekday == 1) ? 7 : weekday - 1
    }
    //  Vaccines
    
    /// Calculates the due date for a vaccine based on a reference date (birth date or EDD) and age in days.
    static func vaccineDueDate(from referenceDate: Date, ageDays: Int) -> Date? {
        let calendar = Self.calendar
        return calendar.date(byAdding: .day, value: ageDays, to: referenceDate)
    }
}
