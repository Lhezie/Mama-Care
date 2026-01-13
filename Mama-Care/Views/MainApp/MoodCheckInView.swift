//
//  MoodCheckInView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 03/11/2025.
//

import SwiftUI

struct MoodCheckInView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var selectedTab: Int
    @State private var selectedMood: MoodType?
    @State private var notes = ""
    
    // Navigation States
    @State private var showSupportiveTips = false
    @State private var showPositiveSupport = false
    @State private var showGoodMoodSuccess = false
    @State private var showAIChat = false
    @State private var showCalmingAudio = false
    // Emergency Escalation
    @State private var showContactSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("MamaCare")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Hi, \(viewModel.currentUser?.firstName ?? "there")")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.mamaCarePrimary.ignoresSafeArea(edges: .top))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Main Content
                        VStack(spacing: 32) {
                            
                            // Title Section
                            VStack(spacing: 12) {
                                Text("Daily Mood Check-In")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.mamaCareTextPrimary)
                                
                                Text("How are you feeling today? Take a moment to reflect on your emotional wellbeing.")
                                    .font(.body)
                                    .foregroundColor(.mamaCareTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Mood Selection
                            VStack(spacing: 24) {
                                Text("How are you feeling today?")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "374151"))
                                
                                HStack(spacing: 20) {
                                    MoodCircleButton(mood: .good, isSelected: selectedMood == .good) {
                                        selectedMood = .good
                                    }
                                    
                                    MoodCircleButton(mood: .okay, isSelected: selectedMood == .okay) {
                                        selectedMood = .okay
                                    }
                                    
                                    MoodCircleButton(mood: .notGood, isSelected: selectedMood == .notGood) {
                                        selectedMood = .notGood
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            
                            // Notes Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Additional Notes (Optional)")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "374151"))
                                
                                TextEditor(text: $notes)
                                    .frame(height: 120)
                                    .padding(12)
                                    .background(Color.mamaCareGrayMedium)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.clear, lineWidth: 1)
                                    )
                                
                                if notes.isEmpty {
                                    Text("How are you feeling? What's on your mind today? Any concerns or positive moments you'd like to record...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 16)
                                        .padding(.top, -140) // Overlay placeholder
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Submit Button
                            Button(action: submitCheckIn) {
                                Text("Submit Check-In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedMood == nil ? Color.gray.opacity(0.5) : Color.mamaCarePrimary)
                                    .cornerRadius(12)
                            }
                            .disabled(selectedMood == nil)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSupportiveTips) {
                SupportiveTipsView(
                    onEmergencyContact: {
                        print("Alert Emergency Contact tapped")
                        showSupportiveTips = false
                        // Small delay to allow sheet to dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("Setting showContactSelection = true")
                            print("Current contact count: \(viewModel.emergencyContacts.count)")
                            showContactSelection = true
                        }
                    },
                    onTalkToAI: {
                        showSupportiveTips = false
                        // Small delay to allow sheet to dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showAIChat = true
                        }
                    },
                    onCalmingAudio: {
                        showSupportiveTips = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showCalmingAudio = true
                        }
                    },
                    onDismiss: {
                        // Navigate back to dashboard
                        selectedTab = 0
                    }
                )
            }
            .sheet(isPresented: $showPositiveSupport) {
                PositiveSupportView(
                    onTalkToAI: {
                        showPositiveSupport = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showAIChat = true
                        }
                    },
                    onDone: {
                        showPositiveSupport = false
                        // Navigate back to dashboard
                        selectedTab = 0
                    }
                )
            }
            .alert("Mood Logged!", isPresented: $showGoodMoodSuccess) {
                Button("OK") {
                    // Navigate back to dashboard
                    selectedTab = 0
                }
            } message: {
                Text("Your strength and positivity shine through! Keep nurturing yourself and your little one.")
            }
            .sheet(isPresented: $showAIChat) {
                AIChatView(isPresented: $showAIChat)
            }
            .sheet(isPresented: $showCalmingAudio) {
                CalmingAudioView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showContactSelection) {
                EmergencyContactSelectionView()
                    .environmentObject(viewModel)
                    .onDisappear {
                        // Navigate to dashboard when dismissed
                        selectedTab = 0
                }
            }
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.moodViewModel.saveError.map { AlertItem(message: $0) } },
                set: { _ in viewModel.moodViewModel.saveError = nil }
            )) { item in
                Alert(title: Text("Failed to Save"), message: Text(item.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    struct AlertItem: Identifiable {
        var id = UUID()
        var message: String
    }
    
    private func submitCheckIn() {
        guard let mood = selectedMood else { return }
        
        // Save to ViewModel
        let checkIn = MoodCheckIn(moodType: mood, notes: notes.isEmpty ? nil : notes)
        viewModel.addMoodCheckIn(checkIn)
        
        // Reset form
        selectedMood = nil
        notes = ""
        
        // Trigger Navigation
        switch mood {
        case .good:
            showGoodMoodSuccess = true
        case .okay:
            showPositiveSupport = true
        case .notGood:
            showSupportiveTips = true
        }
    }
    
    //  Helper Methods
    
    private func callContact(_ contact: EmergencyContact) {
        let cleanNumber = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func messageContact(_ contact: EmergencyContact) {
        let cleanNumber = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        // Create a pre-filled message
        let message = "Hi \(contact.name), I'm not feeling great right now and wanted to reach out. - Sent from MamaCare"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "sms:\(cleanNumber)&body=\(encodedMessage)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "sms:\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            // Fallback without body if the first one fails
            UIApplication.shared.open(url)
        }
    }
}

struct MoodCircleButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(getColor(for: mood))
                        .frame(width: 80, height: 80)
                        .shadow(color: getColor(for: mood).opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: getIconName(for: mood))
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: isSelected ? 4 : 0)
                        .scaleEffect(1.1)
                )
                
                Text(mood.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "374151"))
            }
        }
    }
    
    private func getIconName(for mood: MoodType) -> String {
        switch mood {
        case .good: return "face.smiling"
        case .okay: return "face.dashed"
        case .notGood: return "face.smiling.inverse"  // Using inverse smiley for better compatibility
        }
    }
    
    private func getColor(for mood: MoodType) -> Color {
        switch mood {
        case .good: return .mamaCareCompleted // Green
        case .okay: return .mamaCareDue // Yellow/Orange
        case .notGood: return .mamaCareOverdue // Red
        }
    }
}
