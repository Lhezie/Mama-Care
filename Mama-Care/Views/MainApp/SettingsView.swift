//
//  SettingsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var pushNotifications = true
    @State private var dailyReminders = true
    @State private var moodReminders = true
    @State private var darkMode = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    
    // Editable user data
    @State private var email = "lizziliana@gmail.com"
    @State private var phone = "7765086256"
    @State private var country = "UK"
    @State private var expectedDeliveryDate = Date()
    
    // Check-in times
    @State private var firstCheckIn = Date(timeIntervalSince1970: 8 * 3600) // 08:00
    @State private var secondCheckIn = Date(timeIntervalSince1970: 14 * 3600) // 14:00
    @State private var thirdCheckIn = Date(timeIntervalSince1970: 20 * 3600) // 20:00
    
    @State private var isEditingProfile = false
    @State private var isEditingNotifications = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Profile & Settings Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Profile & Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Manage your personal information and app preferences.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    if isEditingProfile {
                        // Editable Profile Fields
                        VStack(spacing: 16) {
                            EditableField(title: "Email", text: $email, keyboardType: .emailAddress)
                            EditableField(title: "Phone", text: $phone, keyboardType: .phonePad)
                            EditableField(title: "Country", text: $country, keyboardType: .default)
                            
                            DatePickerField(title: "Expected Delivery Date", date: $expectedDeliveryDate)
                        }
                        .padding(.vertical, 8)
                    } else {
                        // Display Only Profile Fields
                        VStack(spacing: 12) {
                            ProfileField(title: "Email", value: email)
                            ProfileField(title: "Phone", value: phone)
                            ProfileField(title: "Country", value: country)
                            ProfileField(title: "Expected Delivery Date", value: formatDate(expectedDeliveryDate))
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Edit/Save Button
                    HStack {
                        Spacer()
                        Button(isEditingProfile ? "Save Changes" : "Edit Profile") {
                            withAnimation {
                                isEditingProfile.toggle()
                            }
                        }
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Notifications Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Manage your notification preferences")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    // Notification Toggles
                    VStack(spacing: 16) {
                        ToggleSetting(
                            title: "Push Notifications",
                            subtitle: "Receive app notifications",
                            isOn: $pushNotifications
                        )
                        
                        ToggleSetting(
                            title: "Daily Reminders",
                            subtitle: "Get reminders for daily tasks",
                            isOn: $dailyReminders
                        )
                        
                        ToggleSetting(
                            title: "Mood Check-in Reminders",
                            subtitle: "Daily mood check-in notifications",
                            isOn: $moodReminders
                        )
                    }
                    .padding(.vertical, 8)
                    
                    // Check-in Times (Editable when notifications are on)
                    if moodReminders {
                        VStack(spacing: 12) {
                            Text("Check-in Times")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TimePickerRow(title: "First Check-in", time: $firstCheckIn)
                            TimePickerRow(title: "Second Check-in", time: $secondCheckIn)
                            TimePickerRow(title: "Third Check-in", time: $thirdCheckIn)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // MARK: - App Settings Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("App Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Customize your app experience")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    // App Settings Options
                    VStack(spacing: 16) {
                        ToggleSetting(
                            title: "Dark Mode",
                            subtitle: "Use dark theme (Coming soon)",
                            isOn: $darkMode
                        )
                        
                        StorageSetting()
                    }
                    .padding(.vertical, 8)
                    
                    // Premium Upgrade
                    PremiumUpgrade()
                        .padding(.vertical, 8)
                }
                
                // MARK: - Account Actions Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Actions")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: ExportDataView()) {
                            ActionRow(icon: "square.and.arrow.up", title: "Export My Data", color: .primary)
                        }
                        
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            ActionRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", color: .red)
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            ActionRow(icon: "trash", title: "Delete Account & Data", color: .red)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - App Info Footer
                Section {
                    VStack(spacing: 8) {
                        Text("MamaCare v1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Made with ❤️ for mothers everywhere")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct ProfileField: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct EditableField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
    }
}

struct DatePickerField: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
        }
    }
}

struct ToggleSetting: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 20)
        }
    }
}

struct TimePickerRow: View {
    let title: String
    @Binding var time: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .frame(width: 80)
        }
    }
}

struct StorageSetting: View {
    var body: some View {
        HStack {
            Image(systemName: "icloud")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("iCloud Sync")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("Device-only storage")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PremiumUpgrade: View {
    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Upgrade to Premium")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("£4/month")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle premium upgrade
        }
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// Placeholder views
struct ExportDataView: View {
    var body: some View {
        VStack {
            Text("Export Data")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Export My Data")
    }
}
