//
//  Mama_CareTests.swift
//  Mama-CareTests
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import Testing
import Foundation
import SwiftData
@testable import Mama_Care

struct Mama_CareTests {

    //  Date Helper Tests
    
    @Test func testPregnancyWeekCalculation() {
        // Given: Due date is 2 weeks from now
        let today = Date()
        let calendar = Calendar.current
        guard let dueDate = calendar.date(byAdding: .day, value: 14, to: today) else {
            #expect(Bool(false), "Failed to create date")
            return
        }
        
        // When: We calculate pregnancy week
        // 40 weeks total - 2 weeks remaining = Week 38
        let week = MamaCareDateHelper.pregnancyWeek(edd: dueDate, on: today)
        
        // Then
        #expect(week == 38)
    }
    
    @Test func testPostpartumWeekCalculation() {
        // Given: Baby born 10 days ago
        let today = Date()
        let calendar = Calendar.current
        guard let birthDate = calendar.date(byAdding: .day, value: -10, to: today) else {
            #expect(Bool(false), "Failed to create date")
            return
        }
        
        // When: We calculate postpartum week
        // Days 0-6 = Week 1, Days 7-13 = Week 2
        let week = MamaCareDateHelper.postpartumWeek(birthDate: birthDate, on: today)
        
        // Then
        #expect(week == 2)
    }
    
    @Test func testVaccineDueDate() {
        // Given: Baby born today
        let birthDate = Date()
        
        // When: Vaccine due in 60 days (2 months)
        let dueDate = MamaCareDateHelper.vaccineDueDate(from: birthDate, ageDays: 60)
        
        // Then
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: birthDate, to: dueDate!).day
        #expect(daysDiff == 60)
    }

    //  Encryption Tests
    
    @Test func testEncryptionRoundTrip() {
        // Given
        let originalText = "This is a secret message 🤫"
        let service = EncryptionService.shared
        
        // When
        guard let encryptedData = service.encryptString(originalText) else {
            #expect(Bool(false), "Encryption failed")
            return
        }
        
        guard let decryptedText = service.decryptString(encryptedData) else {
            #expect(Bool(false), "Decryption failed")
            return
        }
        
        // Then
        #expect(originalText == decryptedText)
        #expect(originalText != String(data: encryptedData, encoding: .utf8) ?? "")
    }
    
    //  Privacy / SwiftData Tests
    
    @MainActor
    @Test func testUserDataSeparation() async throws {
        // Given: An in-memory database service
        let service = SwiftDataService(inMemory: true)
        
        // Create User A (Cloud)
        let userA = UserProfile(uid: "user_a_123", firstName: "Alice")
        try service.saveUserProfile(userA)
        
        // Create User B (Cloud)
        let userB = UserProfile(uid: "user_b_456", firstName: "Bob")
        try service.saveUserProfile(userB)
        
        // Create User C (Device Only)
        let userC = UserProfile(uid: nil, firstName: "Charlie")
        try service.saveUserProfile(userC)
        
        // When: Fetching for User A
        let fetchedA = service.fetchUserProfile(for: "user_a_123")
        #expect(fetchedA?.firstName == "Alice")
        
        // When: Fetching for User B
        let fetchedB = service.fetchUserProfile(for: "user_b_456")
        #expect(fetchedB?.firstName == "Bob")
        
        // When: Fetching for Device Only (nil)
        let fetchedC = service.fetchUserProfile(for: nil)
        #expect(fetchedC?.firstName == "Charlie")
        
        // Verify: User A cannot see User B's data
        // (Implicit in the fetch logic, but good to verify the fetch returns the specific one)
        #expect(fetchedA?.uid != fetchedB?.uid)
    }
    
    @MainActor
    @Test func testDeviceOnlyFallback() async throws {
        // Given: Only a device-only user exists
        let service = SwiftDataService(inMemory: true)
        let userC = UserProfile(uid: nil, firstName: "Charlie")
        try service.saveUserProfile(userC)
        
        // When: Fetching with nil (Device Only mode)
        let fetched = service.fetchUserProfile(for: nil)
        
        // Then
        #expect(fetched?.firstName == "Charlie")
    }
}
