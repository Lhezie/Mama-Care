//
//  SettingsView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    // Profile fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var mobileNumber: String = ""
    
    // Notification settings
    @State private var notificationsEnabled: Bool = true
    @State private var firstCheckInTime = Date()
    @State private var secondCheckInTime = Date()
    @State private var thirdCheckInTime = Date()
    
    // Important dates
    @State private var expectedDeliveryDate = Date()
    @State private var birthDate = Date()
    
    // Alerts
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationText = ""
    @State private var showSaveSuccess = false
    @State private var showDateChangeConfirmation = false
    @State private var deleteError: String?
    @State private var showDeleteError = false
    
    var body: some View {
        NavigationView {
            Form {
                //  Profile Section
                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Mobile Number", text: $mobileNumber)
                        .keyboardType(.phonePad)
                    
                    Button("Save Changes") {
                        saveProfile()
                    }
                    
                    .foregroundColor(.mamaCarePrimary)
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                } header: {
                    Text("Profile")
                }
                
                //  Important Dates Section
                Section {
                    if viewModel.currentUser?.userType == .pregnant {
                        DatePicker("Expected Delivery Date", 
                                   selection: $expectedDeliveryDate,
                                   displayedComponents: .date)
                    } else if viewModel.currentUser?.userType == .hasChild {
                        DatePicker("Child's Birth Date",
                                   selection: $birthDate,
                                   in: ...Date(),
                                   displayedComponents: .date)
                    }
                    
                    Button("Save Date Changes") {
                        showDateChangeConfirmation = true
                    }
                    .foregroundColor(.mamaCarePrimary)
                } header: {
                    Text("Important Dates")
                } footer: {
                    Text("Changing this date will recalculate your vaccine schedule and content.")
                        .font(.caption)
                }
                
                //  Notifications Section
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.mamaCarePrimary)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            handleNotificationToggle(newValue)
                        }
                    
                    if notificationsEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                DatePicker("First Check-in", selection: $firstCheckInTime, displayedComponents: .hourAndMinute)
                            }
                            
                            HStack {
                                DatePicker("Second Check-in", selection: $secondCheckInTime, displayedComponents: .hourAndMinute)
                            }
                            
                            HStack {
                                DatePicker("Third Check-in", selection: $thirdCheckInTime, displayedComponents: .hourAndMinute)
                            }
                        }
                        
                        Button("Save Notification Settings") {
                            saveNotificationTimes()
                        }
                        .foregroundColor(.mamaCarePrimary)
                    }
                } header: {
                    Text("Mood Check-in Reminders")
                } footer: {
                    if notificationsEnabled {
                        Text("You'll receive daily reminders at these times to check in on your mood.")
                    }
                }
                
                //  Automatic Escalation Section
                Section {
                    if viewModel.currentUser?.isPremium == true {
                        Toggle("Allow Automatic Escalation", isOn: Binding(
                            get: { viewModel.currentUser?.escalationEnabled ?? false },
                            set: { viewModel.updateEscalationPreference(enabled: $0) }
                        ))
                        .tint(.red)
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Allow Automatic Escalation")
                                    .foregroundColor(.secondary)
                                Text("Premium Feature")
                                    .font(.caption)
                                    .foregroundColor(.mamaCarePrimary)
                            }
                            Spacer()
                            NavigationLink(destination: PaywallView().environmentObject(viewModel)) {
                                Text("Upgrade")
                                    .font(.subheadline)
                                    .foregroundColor(.mamaCarePrimary)
                            }
                        }
                    }
                } header: {
                    Text("Safety Check")
                } footer: {
                    if viewModel.currentUser?.isPremium == true {
                        Text("If enabled, the app will attempt to alert your contacts if you haven't checked in for 48 hours (requires app to be opened).")
                            .font(.caption)
                    } else {
                        Text("Upgrade to Premium to enable automatic emergency escalation when you miss check-ins for 48 hours.")
                            .font(.caption)
                    }
                }
                
                //  Subscription Section
                Section {
                    if viewModel.currentUser?.isPremium == true {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Premium Member")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        NavigationLink(destination: PaywallView().environmentObject(viewModel)) {
                            HStack {
                                Image(systemName: "crown")
                                    .foregroundColor(.mamaCarePrimary)
                                Text("Upgrade to Premium")
                                Spacer()
                                Text(SubscriptionService.shared.getPricing(for: viewModel.currentUser?.country ?? "United Kingdom"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                //  Account Section
                Section {
                    Button(action: {
                        exportMoodData()
                    }) {
                        Label("Export Mood History", systemImage: "square.and.arrow.up")
                            .foregroundColor(.mamaCarePrimary)
                    }
                    
                    Button("Logout") {
                        showLogoutAlert = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Delete Account") {
                        showDeleteAlert = true
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Account")
                } footer: {
                    Text("Deleting your account is permanent and cannot be undone.")
                        .font(.caption)
                }
                
                //  App Info
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("MamaCare v1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("© 2025 MamaCare")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadUserData()
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout? Your data will be preserved.")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showDeleteConfirmation = true
                }
            } message: {
                Text("This will permanently delete your account and ALL data. This action CANNOT be undone.\n\nAre you absolutely sure?")
            }
            .alert("Type DELETE to Confirm", isPresented: $showDeleteConfirmation) {
                TextField("Type DELETE", text: $deleteConfirmationText)
                Button("Cancel", role: .cancel) {
                    deleteConfirmationText = ""
                }
                Button("Delete Forever", role: .destructive) {
                    if deleteConfirmationText.uppercased() == "DELETE" {
                        deleteAccount()
                    } else {
                        deleteError = "You must type DELETE to confirm."
                        showDeleteError = true
                    }
                    deleteConfirmationText = ""
                }
            } message: {
                Text("Type DELETE (in capital letters) to confirm account deletion.")
            }
            .alert("Error", isPresented: $showDeleteError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(deleteError ?? "An error occurred")
            }
            .alert("Saved", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your changes have been saved successfully.")
            }
            .alert("Update Date?", isPresented: $showDateChangeConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Update") {
                    saveDateChanges()
                }
            } message: {
                Text("This will recalculate your vaccine schedule, nutrition, and postpartum content.")
            }
        }
    }
    
    //  Helper Methods
    
    private func isTimeInPast(_ date: Date) -> Bool {
        return date < Date()
    }
    
    private func loadUserData() {
        guard let user = viewModel.currentUser else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        mobileNumber = user.mobileNumber
        notificationsEnabled = user.notificationsWanted
        
        // Load saved check-in times or use defaults (minutes since midnight)
        let calendar = Calendar.current
        let savedTimes = user.checkInTimes.isEmpty ? [480, 840, 1200] : user.checkInTimes // 08:00, 14:00, 20:00
        
        // Convert minutes since midnight to Date
        firstCheckInTime = dateFromMinutes(savedTimes[0])
        secondCheckInTime = dateFromMinutes(savedTimes[1])
        thirdCheckInTime = dateFromMinutes(savedTimes[2])
        
        // Load important dates
        if let edd = user.expectedDeliveryDate {
            expectedDeliveryDate = edd
        }
        if let birth = user.birthDate {
            birthDate = birth
        }
    }
    
    // Helper to convert minutes since midnight to Date
    private func dateFromMinutes(_ minutes: Int) -> Date {
        let calendar = Calendar.current
        let hour = minutes / 60
        let minute = minutes % 60
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    
    // Helper to convert Date to minutes since midnight
    private func minutesFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return (hour * 60) + minute
    }
    
    private func saveProfile() {
        viewModel.updateProfile(
            firstName: firstName,
            lastName: lastName,
            mobileNumber: mobileNumber
        )
        showSaveSuccess = true
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            let success = await viewModel.toggleNotifications(enabled: enabled)
            if !success {
                // Permission was denied, update UI
                notificationsEnabled = false
            }
        }
    }
    
    private func saveNotificationTimes() {
        let times = [
            minutesFromDate(firstCheckInTime),
            minutesFromDate(secondCheckInTime),
            minutesFromDate(thirdCheckInTime)
        ]
        
        Task {
            do {
                try await viewModel.saveNotificationTimes(times)
                showSaveSuccess = true
            } catch {
                deleteError = error.localizedDescription
                showDeleteError = true // Reusing the generic error alert
            }
        }
    }
    
    private func saveDateChanges() {
        if viewModel.currentUser?.userType == .pregnant {
            viewModel.updateEDD(expectedDeliveryDate)
        } else if viewModel.currentUser?.userType == .hasChild {
            viewModel.updateBirthDate(birthDate)
        }
        showSaveSuccess = true
    }
    
    private func performDeleteAllData() {
        do {
            try viewModel.deleteAllData()
            // Success - user will be automatically returned to onboarding
            print("All data deleted successfully")
        } catch {
            deleteError = error.localizedDescription
            showDeleteError = true
        }
    }
    
    private func exportMoodData() {
        do {
            let fileURL = try viewModel.exportMoodData()
            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootVC.view
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            deleteError = error.localizedDescription
            showDeleteError = true
        }
    }
    
    private func deleteAccount() {
        viewModel.deleteAccount { result in
            switch result {
            case .success:
                print("Account deleted")
            case .failure(let error):
                deleteError = error.localizedDescription
                showDeleteError = true
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MamaCareViewModel())
}
