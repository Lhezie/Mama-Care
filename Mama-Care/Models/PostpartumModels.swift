//
//  PostpartumModels.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import Foundation

//  Postpartum Data Models

struct PostpartumDataWrapper: Codable {
    let postpartumDays: [PostpartumDay]
}

struct PostpartumDay: Codable {
    let dayNumber: Int
    let title: String
    let themes: [String]?  // Optional field - some days have themes, some don't
    let messages: [String]
}
