//
//  SettingsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
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
    
    // Alerts
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Profile Section
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
                
                // MARK: - Notifications Section
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.mamaCarePrimary)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            handleNotificationToggle(newValue)
                        }
                    
                    if notificationsEnabled {
                        DatePicker("First Check-in", selection: $firstCheckInTime, displayedComponents: .hourAndMinute)
                            .onChange(of: firstCheckInTime) { _, _ in
                                updateNotificationTimes()
                            }
                        
                        DatePicker("Second Check-in", selection: $secondCheckInTime, displayedComponents: .hourAndMinute)
                            .onChange(of: secondCheckInTime) { _, _ in
                                updateNotificationTimes()
                            }
                        
                        DatePicker("Third Check-in", selection: $thirdCheckInTime, displayedComponents: .hourAndMinute)
                            .onChange(of: thirdCheckInTime) { _, _ in
                                updateNotificationTimes()
                            }
                    }
                } header: {
                    Text("Mood Check-in Reminders")
                } footer: {
                    if notificationsEnabled {
                        Text("You'll receive daily reminders at these times to check in on your mood.")
                    }
                }
                
                // MARK: - Account Actions Section
                Section {
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
                }
                
                // MARK: - App Info
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
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
            .alert("Saved", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been updated successfully.")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadUserData() {
        guard let user = viewModel.currentUser else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        mobileNumber = user.mobileNumber
        notificationsEnabled = user.notificationsWanted
        
        // Set default times (08:00, 14:00, 20:00)
        let calendar = Calendar.current
        firstCheckInTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        secondCheckInTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
        thirdCheckInTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
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
        viewModel.updateNotificationPreference(enabled: enabled)
        
        if enabled {
            // Request permission and schedule notifications
            Task {
                let granted = await viewModel.notificationService.requestAuthorization()
                if granted {
                    updateNotificationTimes()
                }
            }
        } else {
            // Cancel all notifications
            viewModel.notificationService.cancelMoodCheckInNotifications()
            viewModel.notificationService.cancelAllVaccineReminders()
        }
    }
    
    private func updateNotificationTimes() {
        let calendar = Calendar.current
        let times = [
            calendar.component(.hour, from: firstCheckInTime),
            calendar.component(.hour, from: secondCheckInTime),
            calendar.component(.hour, from: thirdCheckInTime)
        ]
        
        viewModel.notificationService.scheduleMoodCheckInNotifications(times: times)
    }
    
    private func deleteAccount() {
        viewModel.deleteAccount { result in
            switch result {
            case .success:
                print("Account deleted successfully")
            case .failure(let error):
                print("Failed to delete account: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MamaCareViewModel())
}
