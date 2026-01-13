//
//  MamaCareViewModel.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.



import Foundation
import SwiftUI
import Combine
import SwiftData
import Network

@MainActor
class MamaCareViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isOffline = false
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    // Child view models
    let moodViewModel = MoodViewModel()
    let nutritionViewModel = NutritionViewModel()
    let vaccineViewModel = VaccineViewModel()
    
    // Services
    private let authService = AuthService.shared
    private let userService = UserService.shared
    private let moodService = MoodService.shared
    private let swiftDataService = SwiftDataService.shared
    
    let notificationService = NotificationService.shared
    
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var moodCheckIns: [MoodCheckIn] = []
    @Published var vaccineSchedule: [VaccineItem] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var isLoggedIn = false
    @Published var showEmergencyEscalation = false
    @Published var isAILoading = false
    @Published var aiError: String?
    
    // JSON Data
    @Published var nutritionData: NutritionData?
    @Published var vaccineScheduleData: VaccineScheduleData?
    @Published var postpartumDays: [PostpartumDay]?
    
    // JSON Data (Delegated to specialized ViewModels)
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        // Bridge moodCheckIns from MoodViewModel to this VM
        moodViewModel.$moodCheckIns
            .receive(on: DispatchQueue.main)
            .assign(to: &$moodCheckIns)
        
        // Bridge nutrition data
        nutritionViewModel.$nutritionData
            .receive(on: DispatchQueue.main)
            .assign(to: &$nutritionData)
        
        nutritionViewModel.$postpartumDays
            .receive(on: DispatchQueue.main)
            .assign(to: &$postpartumDays)
        
        // Bridge vaccine schedule
        vaccineViewModel.$vaccineSchedule
            .receive(on: DispatchQueue.main)
            .assign(to: &$vaccineSchedule)
        
        vaccineViewModel.$vaccineScheduleData
            .receive(on: DispatchQueue.main)
            .assign(to: &$vaccineScheduleData)
        
        
        
        // Load JSON data (nutrition, vaccines, postpartum tips)
        loadJSONData()
        
        // Setup AI Service
        setupAIServiceSubscription()
        
        // Setup Network Monitoring
        setupNetworkMonitoring()
        
        // Subscribe to Auth State Changes
   
        authService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                
                // Only load if we have completed onboarding
             
                if self.hasCompletedOnboarding {
                    print(" Auth State Updated. Triggering data load.")
                    self.loadUserData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    
    //  Mood Check-In Logic
    
    //  Mood Check-In Logic (delegating to MoodViewModel)
    
    func addMoodCheckIn(_ checkIn: MoodCheckIn) {
        moodViewModel.addMoodCheckIn(checkIn, for: currentUser)
    }
    
    func fetchMoodCheckIns() {
        moodViewModel.fetchMoodCheckIns(for: currentUser)
        
        // Wait slightly for bridge to update then check
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkForMissedCheckIns()
        }
    }
    
    
    func loadChatHistory() {
        guard let userProfile = swiftDataService.fetchUserProfile(for: authService.currentUser?.uid) else { return }
        
        let history = swiftDataService.fetchChatEntries(for: userProfile)
            .map { $0.toChatMessage() }
        
        if history.isEmpty && userProfile.storageMode == .cloud, let uid = authService.currentUser?.uid {
            print(" AI History empty locally, fetching from Cloud...")
            userService.fetchChatHistory(uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("  Failed to fetch remote AI history: \(error.localizedDescription)")
                    }
                } receiveValue: { remoteMessages in
                    AIService.shared.messages = remoteMessages
                    print(" Loaded \(remoteMessages.count) chat messages from Cloud")
                    
                    // Save to local SwiftData for faster access next time
                    Task {
                        for msg in remoteMessages {
                            let entry = ChatEntry.from(msg, user: userProfile)
                            try? self.swiftDataService.saveChatEntry(entry)
                        }
                    }
                }
                .store(in: &cancellables)
        } else {
            AIService.shared.messages = history
            print("Loaded \(history.count) chat messages from Local history")
        }
        
        AIService.shared.currentUserID = userProfile.id
    }
    
    func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
        
        // Save to current user
        if var user = currentUser {
            user.emergencyContacts = emergencyContacts
            currentUser = user
            saveUserData()
            
            // Sync to Firebase if cloud user
            if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
                userService.createUserProfile(user: user, uid: uid)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            print(" Failed to sync emergency contact to Firebase: \(error)")
                        }
                    } receiveValue: {
                        print(" Emergency contact synced to Firebase")
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    
    
    
   
    
    //  Safety Checks
    // Check consent AND premium
    func checkForMissedCheckIns() {
        guard let user = currentUser, user.escalationEnabled, user.isPremium else { return } 
        guard !moodCheckIns.isEmpty else { return }
        
        let sortedCheckIns = moodCheckIns.sorted { $0.date > $1.date }
        if let lastCheckIn = sortedCheckIns.first {
            // Check if last check-in was more than 48 hours ago
            let timeSinceLastCheckIn = Date().timeIntervalSince(lastCheckIn.date)
            let fortyEightHoursInSeconds: TimeInterval = 48 * 3600
            
            if timeSinceLastCheckIn > fortyEightHoursInSeconds {
                print("ALERT: Check-in missed for > 48 hours. Triggering Escalation.")
                showEmergencyEscalation = true
            }
        }
    }
    
    func updateEscalationPreference(enabled: Bool) {
        guard var user = currentUser else { return }
        // Only allow enabling if user is premium
        if enabled && !user.isPremium {
            print("Cannot enable escalation: Premium subscription required")
            return
        }
        user.escalationEnabled = enabled
        currentUser = user
        saveUserData()
    }
    
    //  State Management
    
    /// Clear in-memory user state (used when starting fresh onboarding)
    func clearUserState() {
        currentUser = nil
        emergencyContacts = []
        moodCheckIns = []
        vaccineSchedule = []
        chatMessages = []
        showEmergencyEscalation = false
        
        print(" In-memory user state cleared")
    }
    
    func completeOnboarding(with user: User, password: String, storage: StorageMode?, wantsReminders: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        print(" Starting Onboarding...")
        
        // Clear any old user data from memory before creating new user
        clearUserState()
        
        //  user setup
        var finalUser = user
        finalUser.storageMode = storage ?? .deviceOnly
        finalUser.notificationsWanted = wantsReminders
        finalUser.privacyAcceptedAt = Date()
        
        // Set default notification times if user wants reminders
        if wantsReminders && finalUser.checkInTimes.isEmpty {
            finalUser.checkInTimes = [480, 840, 1200] // 08:00, 14:00, 20:00 in minutes since midnight
            print(" Set default notification times: 08:00, 14:00, 20:00")
        }
        
        //  Device Only Path
        if finalUser.storageMode == .deviceOnly {
            print(" Device Only Mode Selected. Skipping Firebase Auth.")
            
            // 1. Save data locally
            self.currentUser = finalUser
            self.saveUserData() // Encrypted save to SwiftData
            
            // 2. Setup notifications if user wants reminders
            if wantsReminders {
                Task {
                    let granted = await self.notificationService.requestAuthorization()
                    if granted {
                        // Schedule with default times
                        self.notificationService.scheduleMoodCheckInNotifications(times: finalUser.checkInTimes)
                        print(" Mood check-in notifications scheduled at: \(finalUser.checkInTimes)")
                    }
                }
            }
            
            // 3. Complete Login
            print(" completing local login...")
            self.isLoggedIn = true
            self.hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            
            self.loadVaccines()
            completion(.success(()))
            return
        }
        
        // Cloud/Hybrid Path
        //  Create Firebase Account
        print(" Creating Firebase Auth account...")
        authService.signUp(email: user.email, password: password)
            .flatMap { result -> Future<Void, Error> in
                print(" Firebase Auth successful. UID: \(result.user.uid)")
                
                print(" Storage is Cloud: Saving to Firestore...")
                return self.userService.createUserProfile(user: finalUser, uid: result.user.uid)
            }
            .receive(on: DispatchQueue.main)
            .sink { completionStatus in
                switch completionStatus {
                case .failure(let error):
                    print(" Onboarding failed: \(error.localizedDescription)")
                    completion(.failure(error)) // Send error back to UI
                case .finished:
                    print(" Onboarding completed successfully")
                }
            } receiveValue: { _ in
                // Success - Login will be handled by the auth listener or explicit login call
                self.login()
                completion(.success(()))
            }
            .store(in: &cancellables)
    }
    
    //  User Data Persistence
    
    /// Save current user data to SwiftData
    private func saveUserData() {
        guard let user = currentUser else {
            print(" No user to save")
            return
        }
        
        let uid = authService.currentUser?.uid
        
        do {
            if let existingProfile = swiftDataService.fetchUserProfile(for: uid) {
                // UPDATE
                existingProfile.firstName = user.firstName
                existingProfile.lastName = user.lastName
                existingProfile.email = user.email
                existingProfile.country = user.country
                existingProfile.mobileNumber = user.mobileNumber
                existingProfile.userType = user.userType
                existingProfile.expectedDeliveryDate = user.expectedDeliveryDate
                existingProfile.birthDate = user.birthDate
                existingProfile.storageMode = user.storageMode
                existingProfile.privacyAcceptedAt = user.privacyAcceptedAt
                existingProfile.notificationsWanted = user.notificationsWanted
                existingProfile.checkInTimes = user.checkInTimes
                existingProfile.isPremium = user.isPremium
                existingProfile.escalationEnabled = user.escalationEnabled
                
                // Update Emergency Contacts
                // Use direct assignment which leverages SwiftData's relationship management (cascade delete old, insert new)
                let newContacts = user.emergencyContacts.map { Contact.from($0, user: existingProfile) }
                existingProfile.emergencyContacts = newContacts
                
                try swiftDataService.updateUserProfile(existingProfile)
                print("User Profile Updated. Contacts: \(existingProfile.emergencyContacts.count)")
            } else {
                // CREATE
                let profile = UserProfile.from(user)
                profile.uid = uid
                
                // Contacts
                let newContacts = user.emergencyContacts.map { Contact.from($0, user: profile) }
                profile.emergencyContacts = newContacts
                
                try swiftDataService.saveUserProfile(profile)
                print("User Profile Created. Contacts: \(profile.emergencyContacts.count)")
            }
        } catch {
            print(" Error saving user data: \(error)")
        }
    }
    
    /// Load user data from SwiftData (fallback for offline/device-only)
    func loadUserData() {
        // Get current UID if available
        let uid = authService.currentUser?.uid
        
        print(" Loading local user data for UID: \(uid ?? "nil")")
        
        // Try loading from SwiftData first
        // If no UID (Device-Only), fetchUserProfile(for: nil) should find the local-only user
        if let userProfile = swiftDataService.fetchUserProfile(for: uid) {
            currentUser = userProfile.toUser()
            emergencyContacts = currentUser?.emergencyContacts ?? []
            
            print("Loaded User from SwiftData.")
            print("    User: \(currentUser?.firstName ?? "Unknown")")
            print("    Contacts: \(emergencyContacts.count)")
            
            // ALWAYS load mood data from SwiftData
            fetchMoodCheckIns()
            
            // Load Chat History
            loadChatHistory()
            return
        }
        
        print(" No local user profile found.")
    }
    
    //  Offline Support
    
    func checkForLocalUser() -> String? {
        print("MamaCareViewModel: Checking for local user...")
       
        if let profile = swiftDataService.fetchUserProfile(for: nil) {
            print(" MamaCareViewModel: Found local profile using fetchUserProfile(nil). Name: \(profile.firstName)")
            return profile.firstName
        }
        print("MamaCareViewModel: No local profile found.")
        return nil
    }
    
    func loginLocally() {
        print(" Attempting Local Login...")
        loadUserData()
        
        if currentUser != nil {
            isLoggedIn = true
            hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            loadVaccines()
            print("Local Login Successful")
        } else {
            print(" Local Login Failed - No Data")
        }
    }
    
    
    //  App Login State
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print(" Attempting login for \(email)")
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case .failure(let error) = result {
                    print(" Login failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] _ in
                print(" Login successful, fetching profile...")
                self?.login() // Fetch profile
                completion(.success(()))
            }
            .store(in: &cancellables)
    }
    
    func sendPasswordResetEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.sendPasswordResetEmail(email: email)
            .receive(on: DispatchQueue.main)
            .sink { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            } receiveValue: { _ in
                completion(.success(()))
            }
            .store(in: &cancellables)
    }
    
    func login() {
        guard let uid = authService.currentUser?.uid else {
            print(" No current Firebase user")
            return
        }
        
        print(" Fetching user profile for UID: \(uid)")
        userService.fetchUser(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(" Failed to fetch from Cloud: \(error.localizedDescription)")
                    print(" Attempting fallback to Local Storage...")
                    
                    // Fallback: Try to load local data
                    self.loadUserData()
                    
                    if self.currentUser != nil {
                        print(" Found local data. Logging in as Device-Only user.")
                        self.isLoggedIn = true
                        self.hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        self.loadVaccines()
                        self.fetchMoodCheckIns() // Load local moods
                    } else {
                        print(" No local data found either. User has an account but no data on this device.")
                        // Still log them in, but they might need to set up profile?
                        // For now, let's mark as logged in but maybe handle empty user state in UI
                        self.isLoggedIn = true
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    }
                }
            } receiveValue: { [weak self] user in
                print(" Found Cloud data. Logging in as Cloud user.")
                self?.currentUser = user
                self?.emergencyContacts = user.emergencyContacts // Update published property
                self?.isLoggedIn = true
                self?.hasCompletedOnboarding = true
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                self?.saveUserData() // Update local cache
                self?.loadVaccines()
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
            // NOTE: We do NOT delete local data here
            // This allows both device-only and cloud users to keep their data
            // Logout effectively "locks" the app for privacy
            
            // Clear AI Chat history
            AIService.shared.startNewChat()
            
            // Clear in-memory state
            clearUserState()
            
            print(" User logged out (data preserved)")
        } catch {
            print(" Logout failed: \(error.localizedDescription)")
        }
    }
    
    //  Delete Account
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else {
            completion(.failure(NSError(domain: "MamaCareViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "No user to delete"])))
            return
        }
        
        print(" Starting account deletion...")
        
        // Step 1: Handle Device-Only Users
        if user.storageMode == .deviceOnly {
            print(" Device-only user: Clearing local data...")
            self.clearAllLocalData()
            completion(.success(()))
            return
        }
        
        // Step 2: Handle Cloud Users (Delete Firestore + Auth)
        if let uid = authService.currentUser?.uid {
            print(" Deleting cloud data...")
            userService.deleteUserData(uid: uid)
                .flatMap { _ -> Future<Void, Error> in
                    print(" Cloud data deleted")
                    // Delete Firebase Auth account
                    print(" Deleting Firebase Auth account...")
                    return self.authService.deleteAccount()
                }
                .receive(on: DispatchQueue.main)
                .sink { result in
                    switch result {
                    case .failure(let error):
                        print(" Account deletion failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    case .finished:
                        print(" Firebase Auth account deleted")
                        // Clear all local data
                        self.clearAllLocalData()
                        completion(.success(()))
                    }
                } receiveValue: { _ in
                    // Success handled in completion
                }
                .store(in: &cancellables)
        } else {
            // Edge case: User marked as cloud but no Auth user found
            print(" Warning: Cloud user has no active session. Clearing local data only.")
            self.clearAllLocalData()
            completion(.success(()))
        }
    }
    
    //  Clear Local Data
    
    private func clearAllLocalData() {
        print(" Clearing all local data...")
        
        // Clear user data
        currentUser = nil
        isLoggedIn = false
        hasCompletedOnboarding = false
        moodCheckIns = []
        emergencyContacts = []
        
        // Clear SwiftData
        do {
            try swiftDataService.deleteAllData()
            print(" SwiftData cleared")
        } catch {
            print(" Failed to clear SwiftData: \(error)")
        }
        
        // Clear UserDefaults (legacy)
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "moodCheckIns")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Cancel all notifications
        notificationService.cancelAllNotifications()
        
        print(" All local data cleared")
    }
    
    //  Delete All Data (User-Initiated)
    
    func deleteAllData() throws {
        print(" User initiated: Delete All Data")
        
        guard currentUser != nil else {
            throw DataDeletionError.noUserFound
        }
        
        // Step 1: Cancel all notifications
        notificationService.cancelAllNotifications()
        print(" Notifications cancelled")
        
        // Step 2: Clear Firebase data if cloud user
        if currentUser?.storageMode == .cloud, let uid = authService.currentUser?.uid {
            print(" Deleting cloud data for UID: \(uid)")
            // Note: Firebase deletion is async, but we'll proceed with local deletion
            // The cloud data will be deleted in the background
            userService.deleteUserData(uid: uid)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Cloud data deletion failed: \(error.localizedDescription)")
                    }
                } receiveValue: { _ in
                    print(" Cloud data deleted")
                }
                .store(in: &cancellables)
        }
        
        // Step 3: Clear all local data (SwiftData)
        do {
            try swiftDataService.deleteAllData()
            print(" SwiftData cleared")
        } catch {
            print(" SwiftData deletion failed: \(error)")
            throw DataDeletionError.swiftDataDeletionFailed
        }
        
        // Step 4: Clear in-memory data
        currentUser = nil
        isLoggedIn = false
        hasCompletedOnboarding = false
        moodCheckIns = []
        emergencyContacts = []
        vaccineSchedule = []
        
        // Step 5: Clear UserDefaults
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Step 6: Sign out from Firebase
        do {
            try authService.signOut()
            print(" Signed out from Firebase")
        } catch {
            print(" Sign out failed: \(error)")
            throw DataDeletionError.signOutFailed
        }
        
        print(" All data deleted successfully")
    }
    
    //  Export Mood Data
    
    func exportMoodData() throws -> URL {
        try moodViewModel.exportMoodData()
    }
    //  Helpers
    
    func calculateProgress() -> Double {
        guard let user = currentUser else { return 0.0 }
        return Double(user.pregnancyWeek) / Double(user.totalWeeks)
    }
    
    var pregnancyProgressPercentage: Int {
        guard let user = currentUser else { return 0 }
        let progress = Double(user.pregnancyWeek) / Double(user.totalWeeks)
        return Int(min(progress, 1.0) * 100)
    }
    
    var weeksRemaining: Int {
        guard let user = currentUser else { return 0 }
        return max(0, user.totalWeeks - user.pregnancyWeek)
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
            
            // Save to current user
            if var user = currentUser {
                user.emergencyContacts = emergencyContacts
                currentUser = user
                saveUserData()
                
                // Sync to Firebase if cloud user
                if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
                    userService.createUserProfile(user: user, uid: uid)
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            if case .failure(let error) = completion {
                                print(" Failed to sync updated contact to Firebase: \(error)")
                            }
                        } receiveValue: {
                            print(" Updated contact synced to Firebase")
                        }
                        .store(in: &cancellables)
                }
            }
        }
    }
    
    func deleteEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.removeAll(where: { $0.id == contact.id })
        
        // Save to current user
        if var user = currentUser {
            user.emergencyContacts = emergencyContacts
            currentUser = user
            saveUserData()
            
            // Sync to Firebase if cloud user
            if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
                userService.createUserProfile(user: user, uid: uid)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            print(" Failed to sync deleted contact to Firebase: \(error)")
                        }
                    } receiveValue: {
                        print(" Deleted contact synced to Firebase")
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    func updateUserPrivacyAccepted() {
        currentUser?.privacyAcceptedAt = Date()
    }
    
    private func scheduleDailyReminders() {
        // Schedule 3x daily mood check-ins at 08:00, 14:00, 20:00
        // This would use UserNotifications in a real implementation
        print("Scheduling daily reminders at 08:00, 14:00, 20:00")
    }
    
    // Profile Updates
    
    func updateProfile(firstName: String, lastName: String, mobileNumber: String) {
        guard var user = currentUser else { return }
        
        user.firstName = firstName
        user.lastName = lastName
        user.mobileNumber = mobileNumber
        
        currentUser = user
        saveUserData()
        
        // Update in Firebase if cloud user
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to update profile in Firebase: \(error)")
                    }
                } receiveValue: {
                    print(" Profile updated in Firebase")
                }
                .store(in: &cancellables)
        }
        
        print(" Profile updated locally")
    }
    
    func updateNotificationPreference(enabled: Bool) {
        guard var user = currentUser else { return }
        
        user.notificationsWanted = enabled
        currentUser = user
        saveUserData()
        
        // Update in Firebase if cloud user
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to update notification preference in Firebase: \(error)")
                    }
                } receiveValue: {
                    print(" Notification preference updated in Firebase")
                }
                .store(in: &cancellables)
        }
        
        print(" Notification preference updated: \(enabled)")
    }
    
    func updateNotificationTimes(_ times: [Int]) {
        currentUser?.checkInTimes = times
        saveUserData()
        
        // Sync to Firebase if cloud user
        if let user = currentUser, user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to sync notification times: \(error)")
                    }
                } receiveValue: {
                    print("Notification times synced to Firebase")
                }
                .store(in: &cancellables)
        }
    }
    
    //  Notification Management
    
    func toggleNotifications(enabled: Bool) async -> Bool {
        // Update user preference
        currentUser?.notificationsWanted = enabled
        saveUserData()
        
        if enabled {
            // Request permission
            let granted = await notificationService.requestAuthorization()
            if granted {
                // Schedule with current times
                let times = currentUser?.checkInTimes ?? [480, 840, 1200]
                notificationService.scheduleMoodCheckInNotifications(times: times)
                return true
            } else {
                // Permission denied, revert
                currentUser?.notificationsWanted = false
                saveUserData()
                return false
            }
        } else {
            // Cancel all notifications
            notificationService.cancelMoodCheckInNotifications()
            notificationService.cancelAllVaccineReminders()
            return true
        }
    }
    
    func saveNotificationTimes(_ times: [Int]) {
        // Update user data
        currentUser?.checkInTimes = times
        saveUserData()
        
        // Schedule notifications with new times
        notificationService.scheduleMoodCheckInNotifications(times: times)
        
        // Sync to Firebase if cloud user
        if let user = currentUser, user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to sync notification times: \(error)")
                    }
                } receiveValue: {
                    print("Notification times synced to Firebase")
                }
                .store(in: &cancellables)
        }
    }
    
    func updateEDD(_ newDate: Date) {
        guard var user = currentUser else { return }
        
        user.expectedDeliveryDate = newDate
        currentUser = user
        saveUserData()
        
        // Recalculate vaccine schedule
        loadVaccines()
        
        // Update in Firebase if cloud user
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to update EDD in Firebase: \(error)")
                    }
                } receiveValue: {
                    print(" EDD updated in Firebase")
                }
                .store(in: &cancellables)
        }
        
        print(" EDD updated and vaccines recalculated")
    }
    
    func updateBirthDate(_ newDate: Date) {
        guard var user = currentUser else { return }
        
        user.birthDate = newDate
        currentUser = user
        saveUserData()
        
        // Recalculate vaccine schedule
        loadVaccines()
        
        // Update in Firebase if cloud user
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to update birth date in Firebase: \(error)")
                    }
                } receiveValue: {
                    print(" Birth date updated in Firebase")
                }
                .store(in: &cancellables)
        }
        
        print(" Birth date updated and vaccines recalculated")
    }
    
    //  Subscription Management
    
    func updatePremiumStatus(isPremium: Bool) {
        guard var user = currentUser else { return }
        
        user.isPremium = isPremium
        currentUser = user
        saveUserData()
        
        // Update in Firebase if cloud user
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to update premium status in Firebase: \(error)")
                    }
                } receiveValue: {
                    print(" Premium status updated in Firebase")
                }
                .store(in: &cancellables)
        }
        
        print(" Premium status updated: \(isPremium)")
    }
    
    //  Vaccine Management
    
    //  Vaccine Helpers (delegating to VaccineViewModel)
    
    func loadVaccines() {
        vaccineViewModel.loadVaccines(for: currentUser)
    }
    
    func markVaccineAsCompleted(_ vaccine: VaccineItem) {
        // Ensure we have a local user profile saved before attempting to link a vaccine record to it
        saveUserData()
        vaccineViewModel.markVaccineAsCompleted(vaccine)
    }
    
   
    // Network Monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = (path.status == .unsatisfied)
                if path.status == .unsatisfied {
                    print("Network connection lost.")
                } else {
                    print(" Network connection restored.")
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    private func setupAIServiceSubscription() {
        // Subscribe to AIService messages
        AIService.shared.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$chatMessages)
        
        AIService.shared.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAILoading)
        
        AIService.shared.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$aiError)
    }
    
    func sendChatMessage(_ message: String) {
        Task {
            await AIService.shared.sendMessage(message)
        }
    }
    
    //  Subscription Management
    
    func purchaseSubscription() {
        guard let product = SubscriptionService.shared.products.first else {
            print("No product available to purchase")
            return
        }
        
        Task {
            do {
                if let transaction = try await SubscriptionService.shared.purchase(product) {
                    await MainActor.run {
                        self.updatePremiumStatus(isPremium: true)
                    }
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
    
    func restorePurchases() {
        Task {
            await SubscriptionService.shared.restorePurchases()
            let isPremium = SubscriptionService.shared.isPremium
            await MainActor.run {
                self.updatePremiumStatus(isPremium: isPremium)
            }
        }
    }
    
    //  Computed Properties
    
    var userCountry: String {
        return currentUser?.country ?? "United Kingdom"
    }
    
    var isPremium: Bool {
        return currentUser?.isPremium ?? false
    }
    
    //  JSON Data Loading
    
    private func loadJSONData() {
        print(" Loading JSON data...")
        
        // Nutrition + postpartum
        nutritionViewModel.loadNutritionAndPostpartum()
        
        // Vaccines based on current user (if any)
        loadVaccines()
    }
    
    //  Nutrition Helpers (delegating to NutritionViewModel)
    
    func reloadPostpartumData() {
        nutritionViewModel.reloadPostpartumData()
    }
    
    func getCurrentWeekNutrition() -> NutritionWeek? {
        nutritionViewModel.getCurrentWeekNutrition(for: currentUser)
    }
    
    func getCurrentDayNutrition() -> NutritionDay? {
        nutritionViewModel.getCurrentDayNutrition(for: currentUser)
    }
    
    //  Postpartum Helpers
    
    func getPostpartumTip(daysPostpartum: Int) -> PostpartumDay? {
        nutritionViewModel.getPostpartumTip(for: daysPostpartum)
    }
    
    func calculateDaysPostpartum() -> Int? {
        guard let user = currentUser else {
            print(" No current user - cannot calculate days postpartum")
            return nil
        }
        
        guard user.userType == .hasChild else {
            print(" User is not postpartum (userType: \(String(describing: user.userType)))")
            return nil
        }
        
        guard let birthDate = user.birthDate else {
            print(" No birth date set for user")
            return nil
        }
        
        let days = MamaCareDateHelper.daysPostpartum(birthDate: birthDate)
        print(" Calculated \(days) days postpartum from birth date: \(birthDate)")
        
        return days
    }
    
    
    
    //  QR Vaccination Card
    private let qrService = QRService()
    
    func generateVaccineQRData() -> String {
        guard let user = currentUser else { return "No Record Found" }
        
        let dobString = user.birthDate?.formatted(date: .long, time: .omitted) ?? "N/A"
        let completed = vaccineSchedule.filter { $0.status == .completed }
        
        var qrText = """
        MAMA-CARE VACCINATION RECORD
        ----------------------------
        Mother: \(user.firstName) \(user.lastName)
        Child DOB: \(dobString)
        Country: \(user.country)
        
        COMPLETED VACCINES:
        """
        
        if completed.isEmpty {
            qrText += "\nNone recorded yet."
        } else {
            for vaccine in completed {
                let date = vaccine.completedDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
                qrText += "\n• \(vaccine.name) (\(date))"
            }
        }
        
        qrText += "\n\nGenerated: \(Date().formatted(date: .abbreviated, time: .shortened))"
        return qrText
    }
    
    func generateQRImage() -> UIImage? {
        let jsonPayload = generateVaccineQRData()
        return qrService.generateQRCode(from: jsonPayload)
    }
    
    
}
