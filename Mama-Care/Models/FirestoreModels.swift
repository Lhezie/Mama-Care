//
//  FirestoreModels.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import Foundation
import FirebaseFirestore



struct EncryptedContactDTO: Codable {
    var id: String
    var name: Data?
    var relationship: Data?
    var phoneNumber: Data?
    var email: Data?
}

struct EncryptedUserFirestoreData: Codable {
    // I used this to match the Firestore document structure
    let id: String
    let firstName: Data
    let lastName: Data
    let email: Data
    let mobileNumber: Data
    let country: String
    let userType: String?
    let expectedDeliveryDate: Date?
    let birthDate: Date?
    let storageMode: String
    let privacyAcceptedAt: Date?
    let notificationsWanted: Bool
    let checkInTimes: [Int]
    let isPremium: Bool
    let escalationEnabled: Bool
    let emergencyContacts: [EncryptedContactDTO]
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case mobileNumber
        case country
        case userType
        case expectedDeliveryDate
        case birthDate
        case storageMode
        case privacyAcceptedAt
        case notificationsWanted
        case checkInTimes
        case isPremium
        case escalationEnabled
        case emergencyContacts
    }
}

//  Encrypted Mood DTO
struct EncryptedMoodDTO: Codable {
    let id: String
    let date: Date
    let moodType: String
    let encryptedNotes: Data?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case moodType
        case encryptedNotes = "notes" 
    }
}
