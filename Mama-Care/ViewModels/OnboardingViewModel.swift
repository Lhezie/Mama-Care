//
//  OnboardingViewModel.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.



import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {

    @Published var user = User()

    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var acceptedTerms = false
    @Published var acceptedPrivacy = false
    @Published var wantsReminders = true

    @Published var showPersonalInfoError = false
    @Published var showAccountInfoError = false
    @Published var showConsentError = false
    @Published var showDateError = false

    @Published var storageOption: StorageMode? = nil  // Changed to optional
    @Published var selectedDialCode: String = "+44"

    //  Validation
    
    var isPersonalInfoValid: Bool {
        !user.firstName.isEmpty && 
        !user.lastName.isEmpty &&
        !user.country.isEmpty &&
        !user.mobileNumber.isEmpty
    }

    var isAccountInfoValid: Bool {
        !user.email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        isPasswordStrong(password)
    }

    func isPasswordStrong(_ pass: String) -> Bool {
        // Minimum 6 characters, at least one uppercase letter, at least one special character
        let passwordRegex = "^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{6,}$" 
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: pass)
    }

    var canCompleteAccount: Bool {
        acceptedTerms && acceptedPrivacy && storageOption != nil  // Check storage option is set
    }

    //  Date Validation

    var validDateRange: ClosedRange<Date> {
        let today = Date()

        switch user.userType {
        case .pregnant:
            let maxDate = Calendar.current.date(byAdding: .month, value: 9, to: today) ?? today
            return today...maxDate

        case .hasChild:
            let minDate = Calendar.current.date(byAdding: .year, value: -5, to: today) ?? today
            return minDate...today

        default:
            return today...today
        }
    }

    var isDateValid: Bool {
        switch user.userType {
        case .pregnant:
            return user.expectedDeliveryDate != nil
        case .hasChild:
            return user.birthDate != nil
        default:
            return false
        }
    }

    func reset() {
        user = User()
        password = ""
        confirmPassword = ""
        acceptedTerms = false
        acceptedPrivacy = false
        wantsReminders = true
        storageOption = nil  // Reset to nil to require selection
    }
    
    
    
  

    func validateConsent() -> Bool {
        acceptedTerms && acceptedPrivacy && storageOption != nil
    }

    func openLink(_ url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }


}
