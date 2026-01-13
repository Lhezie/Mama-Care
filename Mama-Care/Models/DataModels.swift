//
//  DataModels.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//
import SwiftUI

//  User & Authentication

struct User: Identifiable, Codable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var country: String
    var mobileNumber: String
    var userType: UserType?
    var expectedDeliveryDate: Date?
    var birthDate: Date?
    var storageMode: StorageMode = .deviceOnly
    var privacyAcceptedAt: Date?
    var notificationsWanted: Bool = true
    var checkInTimes: [Int] = [480, 840, 1200] // Minutes since midnight: 08:00 (480), 14:00 (840), 20:00 (1200)
    var emergencyContacts: [EmergencyContact] = []
    var isPremium: Bool = false
    var escalationEnabled: Bool = false
    
    // Add these computed properties
    var pregnancyWeek: Int {
        guard let edd = expectedDeliveryDate,
              userType == .pregnant else { return 0 }
        return MamaCareDateHelper.pregnancyWeek(edd: edd)
    }
    
    var totalWeeks: Int {
        return 40 // Standard pregnancy duration
    }
    
    /// Optional: postpartum week for users with a child.
    var postpartumWeek: Int {
        guard let birthDate = birthDate,
              userType == .hasChild else { return 0 }
        return MamaCareDateHelper.postpartumWeek(birthDate: birthDate)
    }
    
    init(firstName: String = "", lastName: String = "", email: String = "", country: String = "United Kingdom", mobileNumber: String = "", userType: UserType? = nil, expectedDeliveryDate: Date? = nil, birthDate: Date? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.country = country
        self.mobileNumber = mobileNumber
        self.userType = userType
        self.expectedDeliveryDate = expectedDeliveryDate
        self.birthDate = birthDate
    }
    
    var needsOnboarding: Bool {
        userType == nil ||
        (userType == .pregnant && expectedDeliveryDate == nil) ||
        (userType == .hasChild && birthDate == nil)
    }
}

enum UserType: String, CaseIterable, Codable {
    case pregnant = "I am pregnant"
    case hasChild = "I have a child"

        var emoji: String {
            switch self {
            case .pregnant: return "🤰"
            case .hasChild: return "👶"
            }
        }
}

enum StorageMode: String, CaseIterable, Codable {
    case deviceOnly = "Device-only"
    case cloud = "Cloud (Firebase)"
}

//  Emergency Contacts

struct EmergencyContact: Identifiable, Codable {
    var id = UUID()
    var name: String
    var relationship: String
    var phoneNumber: String
    var email: String
    
    var hasContactInfo: Bool {
        !phoneNumber.isEmpty || !email.isEmpty
    }
}

//  Mood Tracking

struct MoodCheckIn: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var moodType: MoodType
    var notes: String?
    
    // Custom initializer
    init(date: Date = Date(), moodType: MoodType, notes: String? = nil) {
        self.date = date
        self.moodType = moodType
        self.notes = notes
    }
}

enum MoodType: String, CaseIterable, Codable {
    case good = "Good"
    case okay = "Okay"
    case notGood = "Not Good"
    
    var chartValue: Int {
        switch self {
        case .good: return 3
        case .okay: return 2
        case .notGood: return 1
        }
    }
    
    var color: Color {
        switch self {
        case .good: return .green
        case .okay: return .yellow
        case .notGood: return .red
        }
    }
}

//  Vaccination

//  Vaccine Schedule Models

enum VaccineStatus: String, Codable {
    case upcoming
    case due
    case overdue
    case completed
}

struct VaccineItem: Identifiable, Codable {
    let id: UUID
    let code: String // Stable identifier from JSON
    let name: String
    let ageRange: String
    let description: String
    let dueDate: Date?
    var status: VaccineStatus
    var completedDate: Date?
    
    init(id: UUID = UUID(), code: String, name: String, ageRange: String, description: String, dueDate: Date?, status: VaccineStatus, completedDate: Date? = nil) {
        self.id = id
        self.code = code
        self.name = name
        self.ageRange = ageRange
        self.description = description
        self.dueDate = dueDate
        self.status = status
        self.completedDate = completedDate
    }
}

//  Chat

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

//  UI Models
public struct ConsentPoint: Identifiable {
    public let id = UUID()
    public let color: Color
    public let text: String

    public init(color: Color, text: String) {
        self.color = color
        self.text = text
    }
}

