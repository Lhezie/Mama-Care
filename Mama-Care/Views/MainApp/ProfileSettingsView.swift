//
//  ProfileSettingsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var pushNotifications = true
    @State private var dailyReminders = true
    @State private var moodCheckInReminders = true
    @State private var darkMode = false
    @State private var iCloudSync = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Profile & Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Spacer()
                        
                        Button {
                            // Edit action
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                            .font(.subheadline)
                            .foregroundColor(.mamaCarePrimary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Text("Manage your personal information and\napp preferences")
                        .font(.subheadline)
                        .foregroundColor(.mamaCareTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Profile Section
                    VStack(spacing: 16) {
                        // Profile Picture
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(Color.mamaCarePrimary)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("S")
                                        .font(.system(size: 36, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                            
                            Circle()
                                .fill(Color.mamaCareCompleted)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("✓")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Text(viewModel.currentUser?.firstName ?? "User")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.mamaCareTextPrimary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.mamaCareCompleted)
                                .frame(width: 8, height: 8)
                            Text("Parent")
                                .font(.caption)
                                .foregroundColor(.mamaCareCompleted)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.mamaCareCompletedBg)
                                .cornerRadius(12)
                        }
                        
                        // Profile Info
                        VStack(spacing: 12) {
                            ProfileInfoRow(icon: "envelope", label: "Email", value: "lizziliana@gmail.com")
                            ProfileInfoRow(icon: "flag", label: "Country", value: "UK")
                            ProfileInfoRow(icon: "calendar", label: "Child's Birth Date", value: "10/10/2025")
                        }
                        .padding()
                        .background(Color.mamaCareGrayLight)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.mamaCareUpcoming)
                            Text("Notifications")
                                .font(.headline)
                                .foregroundColor(.mamaCareTextPrimary)
                        }
                        
                        Text("Manage your notification preferences")
                            .font(.caption)
                            .foregroundColor(.mamaCareTextSecondary)
                        
                        VStack(spacing: 12) {
                            ToggleRow(title: "Push Notifications", subtitle: "Receive app notifications", isOn: $pushNotifications)
                            ToggleRow(title: "Daily Reminders", subtitle: "Get reminders for daily tasks", isOn: $dailyReminders)
                            ToggleRow(title: "Mood Check-in Reminders", subtitle: "Daily mood check-in notifications", isOn: $moodCheckInReminders)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // App Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.mamaCarePurple)
                            Text("App Settings")
                                .font(.headline)
                                .foregroundColor(.mamaCareTextPrimary)
                        }
                        
                        Text("Customize your app experience")
                            .font(.caption)
                            .foregroundColor(.mamaCareTextSecondary)
                        
                        VStack(spacing: 12) {
                            ToggleRow(title: "Dark Mode", subtitle: "Use dark theme (Coming soon)", isOn: $darkMode)
                            ToggleRow(title: "iCloud Sync", subtitle: "Sync data across devices", isOn: $iCloudSync)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Premium Button
                    Button {
                        // Upgrade action
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium (£4/month)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mamaCareDue, .mamaCareOrange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Account Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account Actions")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        VStack(spacing: 12) {
                            ActionButton(icon: "square.and.arrow.up", title: "Export My Data", action: {})
                            ActionButton(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", action: {})
                            ActionButton(icon: "trash", title: "Delete Account & Data", isDestructive: true, action: {})
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Version Info
                    Text("MamaCare v3.0.0 • Made with ❤️ for mothers\neverywhere")
                        .font(.caption2)
                        .foregroundColor(.mamaCareTextTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                }
            }
            .background(Color.mamaCareGrayLight.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.mamaCareTextSecondary)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.mamaCareTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.mamaCareTextPrimary)
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.mamaCareTextPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.mamaCareTextSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.mamaCarePrimary)
        }
        .padding()
        .background(Color.mamaCareGrayLight)
        .cornerRadius(8)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .mamaCareOverdue : .mamaCareTextPrimary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isDestructive ? .mamaCareOverdue : .mamaCareTextPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.mamaCareTextTertiary)
            }
            .padding()
            .background(Color.mamaCareGrayLight)
            .cornerRadius(8)
        }
    }
}
