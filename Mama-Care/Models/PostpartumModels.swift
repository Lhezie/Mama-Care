//
//  PostpartumModels.swift
//  Mama-Care
//
//  Created for JSON data integration
//

import Foundation

// MARK: - Postpartum Data Models

struct PostpartumDataWrapper: Codable {
    let postpartumDays: [PostpartumDay]
}

struct PostpartumDay: Codable {
    let dayNumber: Int
    let title: String
    let themes: [String]?  // Optional field - some days have themes, some don't
    let messages: [String]
}
