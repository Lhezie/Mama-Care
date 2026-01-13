//
//  SwiftDataModels.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import SwiftData
import SwiftUI

//  UserProfile (SwiftData)

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var uid: String? // Firebase User ID (optional, nil for device-only users)
    
    // Encrypted Storage
    var encryptedFirstName: Data?
    var encryptedLastName: Data?
    var encryptedEmail: Data?
    var encryptedMobileNumber: Data?
    var encryptedExpectedDeliveryDate: Data? // Stored as ISO8601 String -> Encrypted Data
    var encryptedBirthDate: Data?
    
    var country: String // Not considered PII for this context, kept plaintext for potential analytics/locales
    var userTypeRaw: String?
    var storageModeRaw: String
    var privacyAcceptedAt: Date?
    var notificationsWanted: Bool
    var checkInTimes: [Int]
    var isPremium: Bool
    var escalationEnabled: Bool
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Contact.user)
    var emergencyContacts: [Contact]
    
    @Relationship(deleteRule: .cascade, inverse: \MoodEntry.user)
    var moodEntries: [MoodEntry]
    
    @Relationship(deleteRule: .cascade, inverse: \VaccineRecord.user)
    var vaccineRecords: [VaccineRecord]
    
    @Relationship(deleteRule: .cascade, inverse: \ChatEntry.user)
    var chatEntries: [ChatEntry]
    
    //  Computed Properties (Decryption/Encryption)
    
    var firstName: String {
        get { decrypt(encryptedFirstName) }
        set { encryptedFirstName = encrypt(newValue) }
    }
    
    var lastName: String {
        get { decrypt(encryptedLastName) }
        set { encryptedLastName = encrypt(newValue) }
    }
    
    var email: String {
        get { decrypt(encryptedEmail) }
        set { encryptedEmail = encrypt(newValue) }
    }
    
    var mobileNumber: String {
        get { decrypt(encryptedMobileNumber) }
        set { encryptedMobileNumber = encrypt(newValue) }
    }
    
    var expectedDeliveryDate: Date? {
        get { decryptDate(encryptedExpectedDeliveryDate) }
        set { encryptedExpectedDeliveryDate = encryptDate(newValue) }
    }
    
    var birthDate: Date? {
        get { decryptDate(encryptedBirthDate) }
        set { encryptedBirthDate = encryptDate(newValue) }
    }
    
    //  Other Computed Properties
    
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
        uid: String? = nil,
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
        checkInTimes: [Int] = [8, 14, 20],
        isPremium: Bool = false,
        escalationEnabled: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.uid = uid
        self.country = country
        self.userTypeRaw = userType?.rawValue
        self.storageModeRaw = storageMode.rawValue
        self.privacyAcceptedAt = privacyAcceptedAt
        self.notificationsWanted = notificationsWanted
        self.checkInTimes = checkInTimes
        self.isPremium = isPremium
        self.escalationEnabled = escalationEnabled
        self.createdAt = createdAt
        self.emergencyContacts = []
        self.moodEntries = []
        self.vaccineRecords = []
        self.chatEntries = []
        
    
        
        self.encryptedFirstName = nil
        self.encryptedLastName = nil
        self.encryptedEmail = nil
        self.encryptedMobileNumber = nil
        self.encryptedExpectedDeliveryDate = nil
        self.encryptedBirthDate = nil
        
        // Now self is initialized, we can use the setters
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.mobileNumber = mobileNumber
        self.expectedDeliveryDate = expectedDeliveryDate
        self.birthDate = birthDate
    }
    
    //  Encryption Helpers
    
    private func encrypt(_ string: String) -> Data? {
        guard !string.isEmpty else { return nil }
        return EncryptionService.shared.encryptString(string)
    }
    
    private func decrypt(_ data: Data?) -> String {
        guard let data = data else { return "" }
        return EncryptionService.shared.decryptString(data) ?? ""
    }
    
    private func encryptDate(_ date: Date?) -> Data? {
        guard let date = date else { return nil }
        let isoString = ISO8601DateFormatter().string(from: date)
        return EncryptionService.shared.encryptString(isoString)
    }
    
    private func decryptDate(_ data: Data?) -> Date? {
        guard let data = data,
              let isoString = EncryptionService.shared.decryptString(data) else { return nil }
        return ISO8601DateFormatter().date(from: isoString)
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
        user.checkInTimes = checkInTimes
        user.isPremium = isPremium
        user.escalationEnabled = escalationEnabled
        user.emergencyContacts = emergencyContacts.map { $0.toEmergencyContact() }
        // Note: Chat messages aren't in the legacy User struct, but can be accessed via MamaCareViewModel
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
            notificationsWanted: user.notificationsWanted,
            checkInTimes: user.checkInTimes,
            isPremium: user.isPremium,
            escalationEnabled: user.escalationEnabled
        )
        return profile
    }
}

//  MoodEntry (SwiftData)

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

//  Contact (SwiftData)

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var encryptedName: Data?  // Made optional to handle encryption failures
    var encryptedRelationship: Data?
    var encryptedPhoneNumber: Data?
    var encryptedEmail: Data?
    
    // Relationship
    var user: UserProfile?
    
    // Decrypted properties
    var name: String {
        get {
            guard let data = encryptedName else { return "" }
            return EncryptionService.shared.decryptString(data) ?? ""
        }
        set {
            encryptedName = EncryptionService.shared.encryptString(newValue)
        }
    }
    
    var relationship: String {
        get {
            guard let data = encryptedRelationship else { return "" }
            return EncryptionService.shared.decryptString(data) ?? ""
        }
        set {
            encryptedRelationship = EncryptionService.shared.encryptString(newValue)
        }
    }
    
    var phoneNumber: String {
        get {
            guard let data = encryptedPhoneNumber else { return "" }
            return EncryptionService.shared.decryptString(data) ?? ""
        }
        set {
            encryptedPhoneNumber = EncryptionService.shared.encryptString(newValue)
        }
    }
    
    var email: String {
        get {
            guard let data = encryptedEmail else { return "" }
            return EncryptionService.shared.decryptString(data) ?? ""
        }
        set {
            encryptedEmail = EncryptionService.shared.encryptString(newValue)
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
        self.encryptedName = EncryptionService.shared.encryptString(name)
        self.encryptedRelationship = EncryptionService.shared.encryptString(relationship)
        self.encryptedPhoneNumber = EncryptionService.shared.encryptString(phoneNumber)
        self.encryptedEmail = EncryptionService.shared.encryptString(email)
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

//  Vaccine Record (SwiftData)

@Model
final class VaccineRecord {
    @Attribute(.unique) var id: UUID
    var code: String // Matches the code in VaccineItem
    var completedDate: Date
    
    // Relationship back to user
    var user: UserProfile?
    
    init(id: UUID = UUID(), code: String, completedDate: Date = Date(), user: UserProfile? = nil) {
        self.id = id
        self.code = code
        self.completedDate = completedDate
        self.user = user
    }
}

//  Chat Entry (SwiftData)

@Model
final class ChatEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var isUser: Bool
    var encryptedContent: Data?
    
    // Relationship
    var user: UserProfile?
    
    // Decrypted content
    var content: String {
        get {
            guard let encrypted = encryptedContent else { return "" }
            return EncryptionService.shared.decryptString(encrypted) ?? ""
        }
        set {
            if !newValue.isEmpty {
                encryptedContent = EncryptionService.shared.encryptString(newValue)
            } else {
                encryptedContent = nil
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        isUser: Bool,
        content: String,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.isUser = isUser
        self.user = user
        
        // Encrypt content
        if !content.isEmpty {
            self.encryptedContent = EncryptionService.shared.encryptString(content)
        }
    }
    
    // Convert to legacy ChatMessage struct
    func toChatMessage() -> ChatMessage {
        return ChatMessage(id: id, content: content, isUser: isUser, timestamp: date)
    }
    
    // Create from legacy ChatMessage struct
    static func from(_ message: ChatMessage, user: UserProfile?) -> ChatEntry {
        return ChatEntry(
            id: message.id,
            date: message.timestamp,
            isUser: message.isUser,
            content: message.content,
            user: user
        )
    }
}
