//
//  MamaCareViewModel.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//


import Foundation
import SwiftUI
import Combine

class MamaCareViewModel: ObservableObject {
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    // Services
    private let authService = AuthService.shared
    private let userService = UserService.shared
    private let moodService = MoodService.shared
       @Published var emergencyContacts: [EmergencyContact] = []
       @Published var moodCheckIns: [MoodCheckIn] = []
       @Published var vaccines: [Vaccine] = []
       @Published var aiChatMessages: [AIChatMessage] = []
       @Published var vaccineSchedule: [VaccineItem] = []
       @Published var chatMessages: [ChatMessage] = []
       @Published var currentOnboardingStep = 0
       @Published var isLoggedIn = false
       @Published var showAIConsent = false
       
       // JSON Data
       @Published var nutritionData: NutritionData?
       @Published var vaccineScheduleData: VaccineScheduleData?
       @Published var postpartumDays: [PostpartumDay]?

       @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

       init() {
           self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
           
           // Load user's data from storage (if they've completed onboarding)
           loadUserData()
           
           // Load JSON data (nutrition, vaccines, postpartum tips)
           loadJSONData()
       }
    
     // MARK: - Mood Check-In Logic
    
    func addMoodCheckIn(_ checkIn: MoodCheckIn) {
        // 1. Update local state immediately for UI responsiveness
        moodCheckIns.insert(checkIn, at: 0)
        
        guard let user = currentUser else { return }
        
        // 2. Persist based on Storage Mode
        if user.storageMode == .cloud {
            guard let uid = authService.currentUser?.uid else { return }
            print("☁️ Saving mood to Cloud...")
            moodService.addMood(checkIn, userID: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to save mood to Cloud: \(error.localizedDescription)")
                    }
                } receiveValue: {
                    print("✅ Mood saved to Cloud")
                }
                .store(in: &cancellables)
        } else {
            print("📱 Saving mood locally (Encrypted)...")
            saveMoodsLocally()
        }
    }
    
    func fetchMoodCheckIns() {
        guard let user = currentUser else { return }
        
        if user.storageMode == .cloud {
            guard let uid = authService.currentUser?.uid else { return }
            print("☁️ Fetching moods from Cloud...")
            moodService.fetchMoods(userID: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to fetch moods from Cloud: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] moods in
                    self?.moodCheckIns = moods
                    print("✅ Fetched \(moods.count) moods from Cloud")
                }
                .store(in: &cancellables)
        } else {
            print("📱 Loading moods locally (Decrypted)...")
            loadMoodsLocally()
        }
    }
    
    // MARK: - Local Mood Persistence (Encrypted)
    
    private func saveMoodsLocally() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(moodCheckIns)
            
            if let encryptedData = EncryptionService.shared.encrypt(data: data) {
                UserDefaults.standard.set(encryptedData, forKey: "moodCheckIns")
                print("🔒 Moods encrypted and saved locally")
            }
        } catch {
            print("❌ Failed to encode moods: \(error)")
        }
    }
    
    private func loadMoodsLocally() {
        guard let encryptedData = UserDefaults.standard.data(forKey: "moodCheckIns") else { return }
        
        guard let data = EncryptionService.shared.decrypt(data: encryptedData) else {
            print("❌ Failed to decrypt moods")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            moodCheckIns = try decoder.decode([MoodCheckIn].self, from: data)
            print("🔓 Moods decrypted and loaded locally")
        } catch {
            print("❌ Failed to decode moods: \(error)")
        }
    }
    
    func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
    }
//    
//    func updateEmergencyContact(_ updatedContact: EmergencyContact) {
//        if let index = emergencyContacts.firstIndex(where: { $0.id == updatedContact.id }) {
//            emergencyContacts[index] = updatedContact
//        }
//    }
//
//    func deleteEmergencyContact(_ contact: EmergencyContact) {
//        emergencyContacts.removeAll { $0.id == contact.id }
//    }

    
    func completeOnboarding(with user: User, storage: StorageMode?, wantsReminders: Bool) {
        // Prepare user object
        var newUser = user
        newUser.storageMode = storage ?? .deviceOnly
        newUser.notificationsWanted = wantsReminders
        newUser.privacyAcceptedAt = Date()
        
        // We need a password to create the account. 
        // NOTE: The current User struct does NOT have a password field.
        // The OnboardingViewModel has the password.
        // We need to pass the password to this function or handle it differently.
        // For now, I will assume the password needs to be passed here.
        // Since I cannot change the signature easily without breaking calls, 
        // I will check if I can access it or if I need to update the call site.
        // The call site in CreateAccountFlowView uses onboardingVM.user, but onboardingVM has the password.
        
        // Wait, I need to update the signature of completeOnboarding to accept password.
        // But first, let's just put a placeholder or fix the call site in the next step.
        // Actually, I should update the signature now.
    }
    
    func completeOnboarding(with user: User, password: String, storage: StorageMode?, wantsReminders: Bool) {
        print("🔄 Starting Onboarding (Hybrid Mode)...")
        
        // Common user setup
        var finalUser = user
        finalUser.storageMode = storage ?? .deviceOnly
        finalUser.notificationsWanted = wantsReminders
        finalUser.privacyAcceptedAt = Date()
        
        // 1. Always create Firebase Account
        print("☁️ Creating Firebase Auth account...")
        authService.signUp(email: user.email, password: password)
            .flatMap { result -> Future<Void, Error> in
                print("✅ Firebase Auth successful. UID: \(result.user.uid)")
                
                // 2. Check Storage Mode
                if finalUser.storageMode == .cloud {
                    print("☁️ Storage is Cloud: Saving to Firestore...")
                    return self.userService.createUserProfile(user: finalUser, uid: result.user.uid)
                } else {
                    print("📱 Storage is Device-Only: Skipping Firestore...")
                    // Return success immediately without saving to Firestore
                    return Future { promise in promise(.success(())) }
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("❌ Onboarding failed: \(error.localizedDescription)")
                    // Handle error
                case .finished:
                    print("✅ Onboarding completed successfully")
                }
            } receiveValue: { _ in
                // 3. Handle Local Persistence for Device-Only (Cloud mode handles it in login/fetch)
                if finalUser.storageMode == .deviceOnly {
                    print("💾 Saving data locally for Device-Only user")
                    self.currentUser = finalUser
                    self.saveUserData() // Encrypted save
                }
                
                self.login()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Data Persistence
    
    /// Save current user data to UserDefaults (Encrypted)
    private func saveUserData() {
        guard let user = currentUser else {
            print("⚠️ No user to save")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            
            // Encrypt data before saving
            if let encryptedData = EncryptionService.shared.encrypt(data: data) {
                UserDefaults.standard.set(encryptedData, forKey: "currentUser")
                print("🔒 User data encrypted and saved successfully")
            } else {
                print("❌ Failed to encrypt user data")
            }
        } catch {
            print("❌ Failed to encode user data: \(error)")
        }
    }
    
    /// Load user data from UserDefaults (Decrypted)
    private func loadUserData() {
        guard let encryptedData = UserDefaults.standard.data(forKey: "currentUser") else {
            print("⚠️ No saved user data found")
            return
        }
        
        // Decrypt data
        guard let data = EncryptionService.shared.decrypt(data: encryptedData) else {
            print("❌ Failed to decrypt user data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            currentUser = try decoder.decode(User.self, from: data)
            print("🔓 User data decrypted and loaded successfully")
            print("   User type: \(currentUser?.userType?.rawValue ?? "nil")")
        } catch {
            print("❌ Failed to decode user data: \(error)")
        }
    }

        // MARK: - App Login State

        func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            print("🔄 Attempting login for \(email)")
            authService.signIn(email: email, password: password)
                .receive(on: DispatchQueue.main)
                .sink { result in
                    if case .failure(let error) = result {
                        print("❌ Login failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } receiveValue: { [weak self] _ in
                    print("✅ Login successful, fetching profile...")
                    self?.login() // Fetch profile
                    completion(.success(()))
                }
                .store(in: &cancellables)
        }

        func login() {
            guard let uid = authService.currentUser?.uid else {
                print("⚠️ No current Firebase user")
                return
            }
            
            print("🔄 Fetching user profile for UID: \(uid)")
            userService.fetchUser(uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("⚠️ Failed to fetch from Cloud: \(error.localizedDescription)")
                        print("🔄 Attempting fallback to Local Storage...")
                        
                        // Fallback: Try to load local data
                        self.loadUserData()
                        
                        if self.currentUser != nil {
                            print("✅ Found local data. Logging in as Device-Only user.")
                            self.isLoggedIn = true
                            self.hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            self.loadVaccinesFromJSON()
                            self.fetchMoodCheckIns() // Load local moods
                        } else {
                            print("⚠️ No local data found either. User has an account but no data on this device.")
                            // Still log them in, but they might need to set up profile?
                            // For now, let's mark as logged in but maybe handle empty user state in UI
                            self.isLoggedIn = true
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        }
                    }
                } receiveValue: { [weak self] user in
                    print("✅ Found Cloud data. Logging in as Cloud user.")
                    self?.currentUser = user
                    self?.isLoggedIn = true
                    self?.hasCompletedOnboarding = true
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    self?.saveUserData() // Update local cache
                    self?.loadVaccinesFromJSON()
                    self?.fetchMoodCheckIns() // Fetch moods
                }
                .store(in: &cancellables)
        }

        func logout() {
            do {
                try authService.signOut()
                isLoggedIn = false
                currentUser = nil
                hasCompletedOnboarding = false
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "currentUser")
                print("✅ User logged out successfully")
            } catch {
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        }

        // MARK: - Helpers

        func calculateProgress() -> Double {
            guard let user = currentUser else { return 0.0 }
            return Double(user.pregnancyWeek) / Double(user.totalWeeks)
        }
    
    func updateUserStorageMode(_ storageMode: StorageMode) {
        currentUser?.storageMode = storageMode
    }
    
    func updateUserNotifications(_ wantsNotifications: Bool) {
        currentUser?.notificationsWanted = wantsNotifications
    }
    
    func updateEmergencyContact(_ updated: EmergencyContact) {
            if let index = emergencyContacts.firstIndex(where: { $0.id == updated.id }) {
                emergencyContacts[index] = updated
            }
        }

        func deleteEmergencyContact(_ contact: EmergencyContact) {
            emergencyContacts.removeAll(where: { $0.id == contact.id })
        }
    
    func updateUserPrivacyAccepted() {
        currentUser?.privacyAcceptedAt = Date()
    }
    
    private func scheduleDailyReminders() {
        // Schedule 3x daily mood check-ins at 08:00, 14:00, 20:00
        // This would use UserNotifications in a real implementation
        print("Scheduling daily reminders at 08:00, 14:00, 20:00")
    }
    
    // MARK: - Vaccine Management
    
    func markVaccineAsCompleted(_ vaccine: VaccineItem) {
        if let index = vaccineSchedule.firstIndex(where: { $0.id == vaccine.id }) {
            vaccineSchedule[index].status = .completed
            vaccineSchedule[index].completedDate = Date()
        }
    }
    
    // MARK: - Chat Management
    
    func sendChatMessage(_ message: String) {
        // Add user message
        let userMessage = ChatMessage(content: message, isUser: true)
        chatMessages.append(userMessage)
        
        // TODO: Call Gemini API here
        // For now, add a placeholder AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiResponse = ChatMessage(
                content: "Thank you for your message. I'm here to support you during your pregnancy journey. Please remember that I provide general information only and cannot replace medical advice from your healthcare provider.",
                isUser: false
            )
            self.chatMessages.append(aiResponse)
        }
    }
    
    // MARK: - Subscription Management
    
    func purchaseSubscription() {
        // TODO: Implement StoreKit purchase
        print("Purchase subscription tapped")
    }
    
    func restorePurchases() {
        // TODO: Implement StoreKit restore
        print("Restore purchases tapped")
    }
    
    // MARK: - Computed Properties
    
    var userCountry: String {
        return currentUser?.country ?? "United Kingdom"
    }
    
    // MARK: - JSON Data Loading
    
    private func loadJSONData() {
        print("🔄 Loading JSON data...")
        
        // Load nutrition data
        nutritionData = JSONDataLoader.loadNutritionData()
        
        // Load postpartum data
        postpartumDays = JSONDataLoader.loadPostpartumData()
        
        if let days = postpartumDays {
            print("✅ Loaded \(days.count) postpartum days in ViewModel")
        } else {
            print("❌ Failed to load postpartum days in ViewModel")
        }
        
        // Load and process vaccine data
        loadVaccinesFromJSON()
    }
    
    /// Reload postpartum data - useful for debugging or refreshing data
    func reloadPostpartumData() {
        print("🔄 Manually reloading postpartum data...")
        postpartumDays = JSONDataLoader.loadPostpartumData()
        
        if let days = postpartumDays {
            print("✅ Reloaded \(days.count) postpartum days")
        } else {
            print("❌ Failed to reload postpartum days")
        }
    }
    
    // MARK: - Nutrition Helpers
    
    func getCurrentWeekNutrition() -> NutritionWeek? {
        guard let user = currentUser,
              let nutritionData = nutritionData else {
            print("⚠️ No user or nutrition data")
            return nil
        }
        
        let pregnancyWeek = user.pregnancyWeek
        guard pregnancyWeek > 0 else {
            print("⚠️ Invalid pregnancy week: \(pregnancyWeek)")
            return nil
        }
        
        // Try to find the exact week
        if let weekData = nutritionData.weeks.first(where: { $0.week == pregnancyWeek }) {
            print("✅ Found nutrition data for week \(pregnancyWeek)")
            return weekData
        }
        
        // Fallback: Use Week 1 data if specific week not found
        print("⚠️ Week \(pregnancyWeek) not found in nutrition data, using Week 1 as fallback")
        return nutritionData.weeks.first
    }
    
    func getCurrentDayNutrition() -> NutritionDay? {
        guard let weekData = getCurrentWeekNutrition() else {
            return nil
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Convert Sunday=1...Saturday=7 to Monday=1...Sunday=7
        let dayOfWeek = weekday == 1 ? 7 : weekday - 1
        
        return weekData.days.first { $0.day == dayOfWeek }
    }
    
    // MARK: - Postpartum Helpers
    
    func getPostpartumTip(daysPostpartum: Int) -> PostpartumDay? {
        guard let postpartumDays = postpartumDays else {
            print("⚠️ No postpartum data loaded - postpartumDays is nil")
            return nil
        }
        
        print("📊 Postpartum data loaded: \(postpartumDays.count) days available")
        print("🔍 Looking for tip for day \(daysPostpartum)")
        
        // Debug: Print first few day numbers
        let firstFewDays = postpartumDays.prefix(10).map { $0.dayNumber }
        print("   First 10 day numbers: \(firstFewDays)")
        
        // Try to find exact day match
        if let exactMatch = postpartumDays.first(where: { $0.dayNumber == daysPostpartum }) {
            print("✅ Found exact postpartum tip for day \(daysPostpartum)")
            print("   Title: \(exactMatch.title)")
            print("   Messages count: \(exactMatch.messages.count)")
            return exactMatch
        }
        
        // If no exact match, find the closest day that's less than or equal to current day
        let closestDay = postpartumDays
            .filter { $0.dayNumber <= daysPostpartum }
            .max(by: { $0.dayNumber < $1.dayNumber })
        
        if let closest = closestDay {
            print("ℹ️ No exact match for day \(daysPostpartum), using day \(closest.dayNumber) instead")
            print("   Title: \(closest.title)")
            print("   Messages count: \(closest.messages.count)")
            return closest
        }
        
        print("⚠️ No postpartum tip found for day \(daysPostpartum)")
        return nil
    }
    
    func calculateDaysPostpartum() -> Int? {
        guard let user = currentUser else {
            print("⚠️ No current user - cannot calculate days postpartum")
            return nil
        }
        
        // Only calculate for users with children
        guard user.userType == .hasChild else {
            print("ℹ️ User is not postpartum (userType: \(user.userType))")
            return nil
        }
        
        guard let birthDate = user.birthDate else {
            print("⚠️ No birth date set for user")
            return nil
        }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        
        // Ensure days is not negative
        let validDays = max(0, days)
        print("✅ Calculated \(validDays) days postpartum from birth date: \(birthDate)")
        
        return validDays
    }
    
    // MARK: - Vaccine Helpers
    
    func loadVaccinesFromJSON() {
        guard let user = currentUser else {
            print("⚠️ No current user - cannot load vaccines")
            self.vaccineSchedule = []
            return
        }
        
        // Reload vaccine schedule based on user's country
        let country = user.country
        print("🔍 Loading vaccine schedule for country: \(country)")
        vaccineScheduleData = JSONDataLoader.loadVaccineSchedule(country: country)
        
        guard let scheduleData = vaccineScheduleData else {
            print("⚠️ Vaccine schedule data not loaded for \(country)")
            self.vaccineSchedule = []
            return
        }
        
        // Determine the reference date for vaccine calculations
        let referenceDate: Date?
        let userTypeDescription: String
        
        if user.userType == .hasChild, let birthDate = user.birthDate {
            // User has a child - use birth date
            referenceDate = birthDate
            userTypeDescription = "child with birth date"
        } else if user.userType == .pregnant, let edd = user.expectedDeliveryDate {
            // User is pregnant - use expected delivery date
            referenceDate = edd
            userTypeDescription = "pregnant with EDD"
        } else {
            print("ℹ️ User has no birth date or EDD - vaccines not applicable")
            self.vaccineSchedule = []
            return
        }
        
        guard let baseDate = referenceDate else {
            print("⚠️ No reference date available for vaccine calculation")
            self.vaccineSchedule = []
            return
        }
        
        print("✅ Calculating vaccines for \(userTypeDescription)")
        
        var vaccines: [VaccineItem] = []
        let calendar = Calendar.current
        
        for appointment in scheduleData.schedule {
            guard let ageDays = appointment.ageDays else { continue }
            
            // Calculate due date from reference date (birth date or EDD)
            let dueDate = calendar.date(byAdding: .day, value: ageDays, to: baseDate)
            
            // Determine status
            let status = determineVaccineStatus(dueDate: dueDate)
            
            // Create vaccine items from appointment
            if let items = appointment.items {
                // Regular appointment with multiple items
                for item in items {
                    let vaccineItem = VaccineItem(
                        name: item.name,
                        ageRange: appointment.label ?? "As scheduled",
                        description: item.antigens?.joined(separator: ", ") ?? item.name,
                        dueDate: dueDate,
                        status: status
                    )
                    vaccines.append(vaccineItem)
                }
            } else if let code = appointment.code, let name = appointment.name {
                // Adolescent vaccine (single item without items array)
                let vaccineItem = VaccineItem(
                    name: name,
                    ageRange: appointment.label ?? "As scheduled",
                    description: code,
                    dueDate: dueDate,
                    status: status
                )
                vaccines.append(vaccineItem)
            }
        }
        
        print("✅ Loaded \(vaccines.count) vaccines from \(country) schedule")
        self.vaccineSchedule = vaccines
    }
    
    private func determineVaccineStatus(dueDate: Date?) -> VaccineStatus {
        guard let dueDate = dueDate else { return .upcoming }
        
        let calendar = Calendar.current
        let today = Date()
        
        let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
        
        if daysUntilDue < -7 {
            return .overdue
        } else if daysUntilDue <= 0 {
            return .due
        } else {
            return .upcoming
        }
    }
    
    
}
