//
//  DataModels.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//
import SwiftUI
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
    var emergencyContacts: [EmergencyContact] = []
    
    // Add these computed properties
    var pregnancyWeek: Int {
        guard let dueDate = expectedDeliveryDate else { return 0 }
        return calculatePregnancyWeek(from: dueDate)
    }
    
    var totalWeeks: Int {
        return 40 // Standard pregnancy duration
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
    
    private func calculatePregnancyWeek(from dueDate: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weeksDifference = calendar.dateComponents([.weekOfYear], from: today, to: dueDate).weekOfYear ?? 0
        return max(0, 40 - weeksDifference)
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

struct Vaccine: Identifiable, Codable {
    var id = UUID()
    var name: String
    var doseNumber: String
    var recommendedWeek: Int
    var dueDate: Date
    var isCompleted: Bool
    
    // Custom initializer
    init(name: String, doseNumber: String, recommendedWeek: Int, dueDate: Date, isCompleted: Bool = false) {
        self.name = name
        self.doseNumber = doseNumber
        self.recommendedWeek = recommendedWeek
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}

struct AIChatMessage: Identifiable, Codable {
    var id = UUID()
    var content: String
    var isUser: Bool
    var timestamp: Date
    
    // Custom initializer
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - Vaccine Schedule Models

enum VaccineStatus: String, Codable {
    case upcoming
    case due
    case overdue
    case completed
}

struct VaccineItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let ageRange: String
    let description: String
    let dueDate: Date?
    var status: VaccineStatus
    var completedDate: Date?
    
    init(id: UUID = UUID(), name: String, ageRange: String, description: String, dueDate: Date?, status: VaccineStatus, completedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.ageRange = ageRange
        self.description = description
        self.dueDate = dueDate
        self.status = status
        self.completedDate = completedDate
    }
}

// MARK: - Chat Models

struct ChatMessage: Identifiable, Codable {
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



// MARK: - Identifiable Consent Point
public struct ConsentPoint: Identifiable {
    public let id = UUID()
    public let color: Color
    public let text: String

    public init(color: Color, text: String) {
        self.color = color
        self.text = text
    }
}

