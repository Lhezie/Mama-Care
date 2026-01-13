//
//  SwiftDataService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataService {
    static let shared = SwiftDataService()
    
    private var modelContext: ModelContext?
    
    private init() {
        // Empty init - context will be injected later
    }
    
    //  Setup
    
    /// Inject the ModelContext from the app's container
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print(" SwiftDataService: ModelContext initialized")
    }
    
    func getContext() -> ModelContext? {
        return modelContext
    }
    
    //  UserProfile Operations
    
    func saveUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: 
            [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        // Check if profile already exists to prevent duplicate inserts
        do {
            let existingDescriptor = FetchDescriptor<UserProfile>()
            let allExisting = try context.fetch(existingDescriptor)
            
            if allExisting.contains(where: { $0.id == profile.id }) {
                return 
            }
        } catch {
            print("Error checking for existing profile: \(error)")
        }
        
        context.insert(profile)
        try context.save()
        print(" UserProfile saved to SwiftData")
    }
    
    func fetchUserProfile(for uid: String? = nil) -> UserProfile? {
        guard let context = modelContext else {
            print("SwiftDataService: fetchUserProfile failed - Context is nil")
            return nil 
        }
        
        print("SwiftDataService: Fetching profile for uid: \(uid ?? "nil")")
        
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let profiles = try context.fetch(descriptor)
            print("SwiftDataService: Found \(profiles.count) total profiles")
            
            for p in profiles {
                print("   - Profile: ID=\(p.id), UID=\(p.uid ?? "nil"), Created=\(p.createdAt)")
            }
            
            // Filter by UID if provided
            if let uid = uid {
                if let match = profiles.first(where: { $0.uid == uid }) {
                    return match
                }
                return nil
            } else {
                // Return device-only profile or most recent
                if let deviceOnly = profiles.first(where: { $0.uid == nil }) {
                    print(" SwiftDataService: Found device-only profile")
                    return deviceOnly
                }
                print(" SwiftDataService: Returning first available profile (fallback)")
                return profiles.first
            }
        } catch {
            print("Failed to fetch UserProfile: \(error)")
            return nil
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        try context.save()
        print("UserProfile updated")
    }
    
    func deleteUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(profile)
        try context.save()
        print("UserProfile deleted")
    }
    
    //  MoodEntry Operations
    
    func saveMoodEntry(_ entry: MoodEntry) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(entry)
        try context.save()
        print("MoodEntry saved to SwiftData")
    }
    
    func fetchMoodEntries(for user: UserProfile) -> [MoodEntry] {
        guard let context = modelContext else { return [] }
        
        // Fetch all mood entries and filter manually
        // This avoids complex predicate issues with optional relationships
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let allEntries = try context.fetch(descriptor)
            // Filter by user ID manually
            return allEntries.filter { $0.user?.id == user.id }
        } catch {
            print("Failed to fetch MoodEntries: \(error)")
            return []
        }
    }
    
    func fetchAllMoodEntries() -> [MoodEntry] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch all MoodEntries: \(error)")
            return []
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(entry)
        try context.save()
        print("MoodEntry deleted")
    }
    
    //  Contact Operations
    
    func saveContact(_ contact: Contact) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(contact)
        try context.save()
        print("Contact saved to SwiftData")
    }
    
    func fetchContacts(for user: UserProfile) -> [Contact] {
        guard let context = modelContext else { return [] }
        
        // Fetch all contacts and filter manually
        // This avoids complex predicate issues with optional relationships
        let descriptor = FetchDescriptor<Contact>()
        
        do {
            let allContacts = try context.fetch(descriptor)
            // Filter by user ID manually
            return allContacts.filter { $0.user?.id == user.id }
        } catch {
            print("Failed to fetch Contacts: \(error)")
            return []
        }
    }
    
    func deleteContact(_ contact: Contact) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(contact)
        try context.save()
        print("Contact deleted")
    }
    
    //  Vaccine Record Operations
    
    func saveVaccineRecord(_ record: VaccineRecord) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(record)
        try context.save()
        print("VaccineRecord saved to SwiftData")
    }
    
    func fetchVaccineRecords(for user: UserProfile) -> [VaccineRecord] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<VaccineRecord>()
        
        do {
            let allRecords = try context.fetch(descriptor)
            return allRecords.filter { $0.user?.id == user.id }
        } catch {
            print("Failed to fetch VaccineRecords: \(error)")
            return []
        }
    }
    
    //  ChatEntry Operations
    
    func saveChatEntry(_ entry: ChatEntry) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(entry)
        try context.save()
        print(" ChatEntry saved to SwiftData")
    }
    
    func fetchChatEntries(for user: UserProfile) -> [ChatEntry] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<ChatEntry>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let allEntries = try context.fetch(descriptor)
            return allEntries.filter { $0.user?.id == user.id }
        } catch {
            print("Failed to fetch ChatEntries: \(error)")
            return []
        }
    }

    //  Batch Operations
    
    func deleteAllData() throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        // Delete all profiles (cascade will delete related data)
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try context.fetch(profileDescriptor)
        for profile in profiles {
            context.delete(profile)
        }
        
        try context.save()
        print("All SwiftData deleted")
    }
}

