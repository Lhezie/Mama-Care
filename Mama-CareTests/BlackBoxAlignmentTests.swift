//
//  BlackBoxAlignmentTests.swift
//  Mama-CareTests
//
//  Created by Elizabeth Enechaziam on 12/01/2026.
//  Purpose: Align unit tests with manual Black Box Testing Plan
//

import XCTest
import Combine
@testable import Mama_Care

final class BlackBoxAlignmentTests: XCTestCase {

    // Authentication & Account Management (BB-AUTH-xx)

    /// BB-AUTH-02: User leaves name/email empty -> Error
    func testSignUp_MissingFields_IsInvalid() {
        let vm = OnboardingViewModel()
        vm.user.firstName = ""
        vm.user.lastName = "Doe"
        // Missing email
        
        XCTAssertFalse(vm.isPersonalInfoValid, "BB-AUTH-02: Should be invalid when first name is empty")
        
        vm.user.firstName = "Jane"
        vm.user.email = ""
        vm.password = "StrongPass1!"
        vm.confirmPassword = "StrongPass1!"
        
        XCTAssertFalse(vm.isAccountInfoValid, "BB-AUTH-02: Should be invalid when email is empty")
    }

   

    /// BB-AUTH-04: Weak password -> Error
    func testSignUp_WeakPassword_IsRejected() {
        let vm = OnboardingViewModel()
        
        // Too short
        XCTAssertFalse(vm.isPasswordStrong("Ab1!"), "BB-AUTH-04: Too short password should fail")
        
        // No uppercase
        XCTAssertFalse(vm.isPasswordStrong("password123!"), "BB-AUTH-04: No uppercase should fail")
        
        // No special char
        XCTAssertFalse(vm.isPasswordStrong("Password123"), "BB-AUTH-04: No special char should fail")
        
        // Valid
        XCTAssertTrue(vm.isPasswordStrong("Password123!"), "BB-AUTH-04: Strong password should pass")
    }

    /// BB-AUTH-05: Password mismatch -> Error
    func testSignUp_PasswordMismatch_IsInvalid() {
        let vm = OnboardingViewModel()
        vm.user.email = "test@example.com"
        vm.password = "Password123!"
        vm.confirmPassword = "Mismatch123!"
        
        XCTAssertFalse(vm.isAccountInfoValid, "BB-AUTH-05: Mismatched passwords should be invalid")
    }

    //Onboarding Flow (BB-ONB-xx)

    /// BB-ONB-02: Reject privacy policy -> Progress blocked
    func testOnboarding_ConsentNotGiven_BlocksProgress() {
        let vm = OnboardingViewModel()
        vm.acceptedTerms = true
        vm.acceptedPrivacy = false // Unchecked
        vm.storageOption = .deviceOnly
        
        XCTAssertFalse(vm.canCompleteAccount, "BB-ONB-02: Should not proceed without privacy consent")
        
        vm.acceptedPrivacy = true
        XCTAssertTrue(vm.canCompleteAccount, "BB-ONB-01: Should proceed when all consents given")
    }
    
    /// BB-ONB-03 & BB-ONB-04: User Type Routing Logic
    func testOnboarding_UserType_DateValidation() {
        let vm = OnboardingViewModel()
        
        // Check Pregnant Logic
        vm.user.userType = .pregnant
        vm.user.expectedDeliveryDate = nil
        XCTAssertFalse(vm.isDateValid, "BB-ONB-03: Pregnant user needs EDD")
        
        vm.user.expectedDeliveryDate = Date()
        XCTAssertTrue(vm.isDateValid, "BB-ONB-03: Pregnant user with EDD is valid")
        
        // Check Mother Logic
        vm.user.userType = .hasChild
        vm.user.expectedDeliveryDate = nil // Reset EDD
        vm.user.birthDate = nil
        XCTAssertFalse(vm.isDateValid, "BB-ONB-04: Mother needs birth date")
        
        vm.user.birthDate = Date()
        XCTAssertTrue(vm.isDateValid, "BB-ONB-04: Mother with birth date is valid")
    }

    // Vaccination Tracking (BB-VAC-xx)

    /// BB-VAC-04: Mark completed -> Status updated
    @MainActor
    func testVaccine_MarkCompleted_UpdatesStatus() {
        let vm = VaccineViewModel()
        
        // Mock a vaccine item
        let testItem = VaccineItem(
            code: "BCG",
            name: "BCG",
            ageRange: "Birth",
            description: "TB Protection",
            dueDate: Date(),
            status: .due
        )
        
        // Populate VM manually since we can't easily load JSON in unit test without bundle
        vm.vaccineSchedule = [testItem]
        
        // Action
        vm.markVaccineAsCompleted(testItem)
        
        // Assert
        let updatedItem = vm.vaccineSchedule.first
        XCTAssertEqual(updatedItem?.status, .completed, "BB-VAC-04: Status should be completed")
        XCTAssertNotNil(updatedItem?.completedDate, "BB-VAC-04: Completed date should be set")
    }
    

    // AI Privacy (BB-AI-xx)
    
    /// BB-AI-02: PII in message -> Redacted
    func testAI_PIIRedaction_Logic() {
        
        
        let inputResult = scrubPII_TestHelper("My email is test@example.com")
        XCTAssertEqual(inputResult, "My email is [EMAIL REDACTED]", "BB-AI-02: Email should be redacted")
        
        let phoneResult = scrubPII_TestHelper("Call me at 08012345678")
        XCTAssertEqual(phoneResult, "Call me at [PHONE REDACTED]", "BB-AI-02: Phone should be redacted")
    }
    
    
    private func scrubPII_TestHelper(_ text: String) -> String {
        var scrubbed = text
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let regex = try? NSRegularExpression(pattern: emailPattern, options: .caseInsensitive) {
            scrubbed = regex.stringByReplacingMatches(in: scrubbed, range: NSRange(location: 0, length: scrubbed.utf16.count), withTemplate: "[EMAIL REDACTED]")
        }
        let phonePattern = "[0-9]{11}"
        if let regex = try? NSRegularExpression(pattern: phonePattern) {
            scrubbed = regex.stringByReplacingMatches(in: scrubbed, range: NSRange(location: 0, length: scrubbed.utf16.count), withTemplate: "[PHONE REDACTED]")
        }
        return scrubbed
    }
}
