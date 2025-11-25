//
//  SwiftDataService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataService {
    static let shared = SwiftDataService()
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    private init() {
        setupContainer()
    }
    
    // MARK: - Setup
    
    private func setupContainer() {
        do {
            let schema = Schema([
                UserProfile.self,
                MoodEntry.self,
                Contact.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer!)
            
            print("✅ SwiftData container initialized")
        } catch {
            print("❌ Failed to initialize SwiftData: \(error)")
        }
    }
    
    func getContext() -> ModelContext? {
        return modelContext
    }
    
    // MARK: - UserProfile Operations
    
    func saveUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(profile)
        try context.save()
        print("✅ UserProfile saved to SwiftData")
    }
    
    func fetchUserProfile() -> UserProfile? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let profiles = try context.fetch(descriptor)
            return profiles.first
        } catch {
            print("❌ Failed to fetch UserProfile: \(error)")
            return nil
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        try context.save()
        print("✅ UserProfile updated")
    }
    
    func deleteUserProfile(_ profile: UserProfile) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(profile)
        try context.save()
        print("✅ UserProfile deleted")
    }
    
    // MARK: - MoodEntry Operations
    
    func saveMoodEntry(_ entry: MoodEntry) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(entry)
        try context.save()
        print("✅ MoodEntry saved to SwiftData")
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
            print("❌ Failed to fetch MoodEntries: \(error)")
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
            print("❌ Failed to fetch all MoodEntries: \(error)")
            return []
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(entry)
        try context.save()
        print("✅ MoodEntry deleted")
    }
    
    // MARK: - Contact Operations
    
    func saveContact(_ contact: Contact) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.insert(contact)
        try context.save()
        print("✅ Contact saved to SwiftData")
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
            print("❌ Failed to fetch Contacts: \(error)")
            return []
        }
    }
    
    func deleteContact(_ contact: Contact) throws {
        guard let context = modelContext else {
            throw NSError(domain: "SwiftDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "ModelContext not initialized"])
        }
        
        context.delete(contact)
        try context.save()
        print("✅ Contact deleted")
    }
    
    // MARK: - Batch Operations
    
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
        print("✅ All SwiftData deleted")
    }
}
