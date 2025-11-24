//
//  NutritionModels.swift
//  Mama-Care
//
//  Created for JSON data integration
//

import Foundation

// MARK: - Nutrition Data Models

struct NutritionData: Codable {
    let meta: NutritionMeta
    let weeks: [NutritionWeek]
}

struct NutritionMeta: Codable {
    let title: String
    let version: String
    let notes: [String]
}

struct NutritionWeek: Codable {
    let week: Int
    let theme: String
    let days: [NutritionDay]
}

struct NutritionDay: Codable {
    let day: Int
    let headline: String
    let foodSuggestions: [String]
    let waterGoalCups: Int
}
