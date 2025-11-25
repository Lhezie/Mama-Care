//
//  DataMigrationService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import SwiftData

@MainActor
class DataMigrationService {
    static let shared = DataMigrationService()
    private let migrationKey = "hasCompletedSwiftDataMigration"
    
    private init() {}
    
    // MARK: - Migration Check
    
    func needsMigration() -> Bool {
        // Check if migration has already been completed
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("ℹ️ Migration already completed")
            return false
        }
        
        // Check if there's data in UserDefaults to migrate
        let hasUserData = UserDefaults.standard.data(forKey: "currentUser") != nil
        let hasMoodData = UserDefaults.standard.data(forKey: "moodCheckIns") != nil
        
        if hasUserData || hasMoodData {
            print("📦 Found UserDefaults data - migration needed")
            return true
        }
        
        print("ℹ️ No UserDefaults data found - fresh install")
        return false
    }
    
    // MARK: - Perform Migration
    
    func performMigration() async throws {
        print("🔄 Starting migration from UserDefaults to SwiftData...")
        
        // 1. Migrate User Profile
        if let userProfile = try migrateUserProfile() {
            print("✅ User profile migrated")
            
            // 2. Migrate Mood Check-ins
            try migrateMoodCheckIns(for: userProfile)
            print("✅ Mood check-ins migrated")
            
            // 3. Migrate Emergency Contacts
            try migrateEmergencyContacts(for: userProfile)
            print("✅ Emergency contacts migrated")
        }
        
        // 4. Mark migration as complete
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("✅ Migration completed successfully")
    }
    
    // MARK: - User Profile Migration
    
    private func migrateUserProfile() throws -> UserProfile? {
        guard let encryptedData = UserDefaults.standard.data(forKey: "currentUser") else {
            print("ℹ️ No user data to migrate")
            return nil
        }
        
        // Decrypt data
        guard let data = EncryptionService.shared.decrypt(data: encryptedData) else {
            throw NSError(domain: "DataMigration", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decrypt user data"])
        }
        
        // Decode User struct
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        
        // Convert to UserProfile
        let profile = UserProfile.from(user)
        
        // Save to SwiftData
        try SwiftDataService.shared.saveUserProfile(profile)
        
        return profile
    }
    
    // MARK: - Mood Check-ins Migration
    
    private func migrateMoodCheckIns(for user: UserProfile) throws {
        guard let encryptedData = UserDefaults.standard.data(forKey: "moodCheckIns") else {
            print("ℹ️ No mood data to migrate")
            return
        }
        
        // Decrypt data
        guard let data = EncryptionService.shared.decrypt(data: encryptedData) else {
            throw NSError(domain: "DataMigration", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decrypt mood data"])
        }
        
        // Decode MoodCheckIn array
        let decoder = JSONDecoder()
        let moodCheckIns = try decoder.decode([MoodCheckIn].self, from: data)
        
        // Convert and save each mood entry
        for checkIn in moodCheckIns {
            let entry = MoodEntry.from(checkIn, user: user)
            try SwiftDataService.shared.saveMoodEntry(entry)
        }
        
        print("✅ Migrated \(moodCheckIns.count) mood check-ins")
    }
    
    // MARK: - Emergency Contacts Migration
    
    private func migrateEmergencyContacts(for user: UserProfile) throws {
        // Emergency contacts are embedded in the User struct
        // They were already migrated with the user profile
        // But we need to create Contact entities and link them
        
        guard let encryptedData = UserDefaults.standard.data(forKey: "currentUser") else {
            return
        }
        
        guard let data = EncryptionService.shared.decrypt(data: encryptedData) else {
            return
        }
        
        let decoder = JSONDecoder()
        let legacyUser = try decoder.decode(User.self, from: data)
        
        for emergencyContact in legacyUser.emergencyContacts {
            let contact = Contact.from(emergencyContact, user: user)
            try SwiftDataService.shared.saveContact(contact)
        }
        
        print("✅ Migrated \(legacyUser.emergencyContacts.count) emergency contacts")
    }
    
    // MARK: - Cleanup (Optional)
    
    func cleanupOldData() {
        print("🧹 Cleaning up old UserDefaults data...")
        
        // Keep as backup for now, can be removed in future version
        // UserDefaults.standard.removeObject(forKey: "currentUser")
        // UserDefaults.standard.removeObject(forKey: "moodCheckIns")
        
        print("ℹ️ Old data kept as backup")
    }
}
