//
//  MoodCheckInView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct MoodCheckInView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedMood: MoodType?
    @State private var notes = ""
    
    // Navigation States
    @State private var showSupportiveTips = false
    @State private var showPositiveSupport = false
    @State private var showGoodMoodSuccess = false
    
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
                        // Handle emergency contact
                        print("Emergency Contact Tapped")
                    },
                    onTalkToAI: {
                        // Handle AI Chat
                        print("Talk to AI Tapped")
                    },
                    onCalmingAudio: {
                        // Handle Audio
                        print("Calming Audio Tapped")
                    }
                )
            }
            .sheet(isPresented: $showPositiveSupport) {
                PositiveSupportView(
                    onTalkToAI: {
                        // Handle AI Chat
                        print("Talk to AI Tapped")
                    },
                    onDone: {
                        showPositiveSupport = false
                    }
                )
            }
            .alert("Wonderful!", isPresented: $showGoodMoodSuccess) {
                Button("Done", role: .cancel) { }
            } message: {
                Text("Your strength and positivity shine through! Keep nurturing yourself and your little one.")
            }
        }
    }
    
    private func submitCheckIn() {
        guard let mood = selectedMood else { return }
        
        // Save to ViewModel
        let checkIn = MoodCheckIn(moodType: mood, notes: notes.isEmpty ? nil : notes)
        viewModel.addMoodCheckIn(checkIn)
        
        // Trigger Navigation
        switch mood {
        case .good:
            showGoodMoodSuccess = true
        case .okay:
            showPositiveSupport = true
        case .notGood:
            showSupportiveTips = true
        }
        
        // Reset Form (optional, maybe keep it until done?)
        // selectedMood = nil
        // notes = ""
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
        case .notGood: return "face.frown"
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
