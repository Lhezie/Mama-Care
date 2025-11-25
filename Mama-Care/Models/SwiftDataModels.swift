//
//  SwiftDataModels.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - UserProfile (SwiftData)

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var country: String
    var mobileNumber: String
    var userTypeRaw: String? // Store enum as String
    var expectedDeliveryDate: Date?
    var birthDate: Date?
    var storageModeRaw: String // Store enum as String
    var privacyAcceptedAt: Date?
    var notificationsWanted: Bool
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Contact.user)
    var emergencyContacts: [Contact]
    
    @Relationship(deleteRule: .cascade, inverse: \MoodEntry.user)
    var moodEntries: [MoodEntry]
    
    // Computed properties
    var userType: UserType? {
        get {
            guard let raw = userTypeRaw else { return nil }
            return UserType(rawValue: raw)
        }
        set {
            userTypeRaw = newValue?.rawValue
        }
    }
    
    var storageMode: StorageMode {
        get {
            return StorageMode(rawValue: storageModeRaw) ?? .deviceOnly
        }
        set {
            storageModeRaw = newValue.rawValue
        }
    }
    
    var pregnancyWeek: Int {
        guard let dueDate = expectedDeliveryDate else { return 0 }
        return calculatePregnancyWeek(from: dueDate)
    }
    
    var totalWeeks: Int {
        return 40
    }
    
    var needsOnboarding: Bool {
        userType == nil ||
        (userType == .pregnant && expectedDeliveryDate == nil) ||
        (userType == .hasChild && birthDate == nil)
    }
    
    init(
        id: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        country: String = "United Kingdom",
        mobileNumber: String = "",
        userType: UserType? = nil,
        expectedDeliveryDate: Date? = nil,
        birthDate: Date? = nil,
        storageMode: StorageMode = .deviceOnly,
        privacyAcceptedAt: Date? = nil,
        notificationsWanted: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.country = country
        self.mobileNumber = mobileNumber
        self.userTypeRaw = userType?.rawValue
        self.expectedDeliveryDate = expectedDeliveryDate
        self.birthDate = birthDate
        self.storageModeRaw = storageMode.rawValue
        self.privacyAcceptedAt = privacyAcceptedAt
        self.notificationsWanted = notificationsWanted
        self.createdAt = createdAt
        self.emergencyContacts = []
        self.moodEntries = []
    }
    
    private func calculatePregnancyWeek(from dueDate: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weeksDifference = calendar.dateComponents([.weekOfYear], from: today, to: dueDate).weekOfYear ?? 0
        return max(0, 40 - weeksDifference)
    }
    
    // Convert to legacy User struct (for compatibility)
    func toUser() -> User {
        var user = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            country: country,
            mobileNumber: mobileNumber,
            userType: userType,
            expectedDeliveryDate: expectedDeliveryDate,
            birthDate: birthDate
        )
        user.id = id
        user.storageMode = storageMode
        user.privacyAcceptedAt = privacyAcceptedAt
        user.notificationsWanted = notificationsWanted
        user.emergencyContacts = emergencyContacts.map { $0.toEmergencyContact() }
        return user
    }
    
    // Create from legacy User struct
    static func from(_ user: User) -> UserProfile {
        let profile = UserProfile(
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            country: user.country,
            mobileNumber: user.mobileNumber,
            userType: user.userType,
            expectedDeliveryDate: user.expectedDeliveryDate,
            birthDate: user.birthDate,
            storageMode: user.storageMode,
            privacyAcceptedAt: user.privacyAcceptedAt,
            notificationsWanted: user.notificationsWanted
        )
        return profile
    }
}

// MARK: - MoodEntry (SwiftData)

@Model
final class MoodEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var moodTypeRaw: String
    var encryptedNotes: Data? // Encrypted notes
    
    // Relationship
    var user: UserProfile?
    
    // Computed property
    var moodType: MoodType {
        get {
            return MoodType(rawValue: moodTypeRaw) ?? .okay
        }
        set {
            moodTypeRaw = newValue.rawValue
        }
    }
    
    // Decrypted notes
    var notes: String? {
        get {
            guard let encrypted = encryptedNotes else { return nil }
            return EncryptionService.shared.decryptString(encrypted)
        }
        set {
            if let value = newValue, !value.isEmpty {
                encryptedNotes = EncryptionService.shared.encryptString(value)
            } else {
                encryptedNotes = nil
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        moodType: MoodType,
        notes: String? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.moodTypeRaw = moodType.rawValue
        self.user = user
        
        // Encrypt notes if provided
        if let notes = notes, !notes.isEmpty {
            self.encryptedNotes = EncryptionService.shared.encryptString(notes)
        }
    }
    
    // Convert to legacy MoodCheckIn struct
    func toMoodCheckIn() -> MoodCheckIn {
        var checkIn = MoodCheckIn(date: date, moodType: moodType, notes: notes)
        checkIn.id = id
        return checkIn
    }
    
    // Create from legacy MoodCheckIn struct
    static func from(_ checkIn: MoodCheckIn, user: UserProfile?) -> MoodEntry {
        return MoodEntry(
            id: checkIn.id,
            date: checkIn.date,
            moodType: checkIn.moodType,
            notes: checkIn.notes,
            user: user
        )
    }
}

// MARK: - Contact (SwiftData)

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var encryptedName: Data
    var encryptedRelationship: Data
    var encryptedPhoneNumber: Data
    var encryptedEmail: Data
    
    // Relationship
    var user: UserProfile?
    
    // Decrypted properties
    var name: String {
        get {
            EncryptionService.shared.decryptString(encryptedName) ?? ""
        }
        set {
            encryptedName = EncryptionService.shared.encryptString(newValue) ?? Data()
        }
    }
    
    var relationship: String {
        get {
            EncryptionService.shared.decryptString(encryptedRelationship) ?? ""
        }
        set {
            encryptedRelationship = EncryptionService.shared.encryptString(newValue) ?? Data()
        }
    }
    
    var phoneNumber: String {
        get {
            EncryptionService.shared.decryptString(encryptedPhoneNumber) ?? ""
        }
        set {
            encryptedPhoneNumber = EncryptionService.shared.encryptString(newValue) ?? Data()
        }
    }
    
    var email: String {
        get {
            EncryptionService.shared.decryptString(encryptedEmail) ?? ""
        }
        set {
            encryptedEmail = EncryptionService.shared.encryptString(newValue) ?? Data()
        }
    }
    
    var hasContactInfo: Bool {
        !phoneNumber.isEmpty || !email.isEmpty
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        phoneNumber: String,
        email: String,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.encryptedName = EncryptionService.shared.encryptString(name) ?? Data()
        self.encryptedRelationship = EncryptionService.shared.encryptString(relationship) ?? Data()
        self.encryptedPhoneNumber = EncryptionService.shared.encryptString(phoneNumber) ?? Data()
        self.encryptedEmail = EncryptionService.shared.encryptString(email) ?? Data()
        self.user = user
    }
    
    // Convert to legacy EmergencyContact struct
    func toEmergencyContact() -> EmergencyContact {
        var contact = EmergencyContact(
            name: name,
            relationship: relationship,
            phoneNumber: phoneNumber,
            email: email
        )
        contact.id = id
        return contact
    }
    
    // Create from legacy EmergencyContact struct
    static func from(_ contact: EmergencyContact, user: UserProfile?) -> Contact {
        return Contact(
            id: contact.id,
            name: contact.name,
            relationship: contact.relationship,
            phoneNumber: contact.phoneNumber,
            email: contact.email,
            user: user
        )
    }
}
