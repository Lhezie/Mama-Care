//
//  AIChatView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var messageText = ""
    @State private var showDisclaimer = true
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button {
                            // Back action
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.mamaCareTextPrimary)
                        }
                        
                        VStack(spacing: 2) {
                            Text("AI Chat")
                                .font(.headline)
                                .foregroundColor(.mamaCareTextPrimary)
                            
                            Text("Your pregnancy companion")
                                .font(.caption)
                                .foregroundColor(.mamaCareTextSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            // Info action
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .foregroundColor(.mamaCareTextPrimary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Messages
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.chatMessages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .background(Color.mamaCareGrayLight)
                    
                    // Input Area
                    HStack(spacing: 12) {
                        TextField("Type your message...", text: $messageText)
                            .padding()
                            .background(Color.mamaCareGrayMedium)
                            .cornerRadius(24)
                            .focused($isInputFocused)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(messageText.isEmpty ? .mamaCareTextTertiary : .mamaCarePrimary)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                }
                
                // Disclaimer Overlay
                if showDisclaimer {
                    DisclaimerOverlay {
                        showDisclaimer = false
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        viewModel.sendChatMessage(messageText)
        messageText = ""
        isInputFocused = false
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .mamaCareTextPrimary)
                    .padding()
                    .background(message.isUser ? .mamaCarePrimary : Color.white)
                    .cornerRadius(20)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.mamaCareTextTertiary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct DisclaimerOverlay: View {
    let onAccept: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.mamaCareDueBg)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.mamaCareDue)
                }
                
                VStack(spacing: 12) {
                    Text("Important Disclaimer")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.mamaCareTextPrimary)
                    
                    Text("This AI chat is for informational purposes only and does not provide medical advice. Always consult with your healthcare provider for medical concerns.")
                        .font(.body)
                        .foregroundColor(.mamaCareTextDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button {
                    onAccept()
                } label: {
                    Text("I Understand")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mamaCarePrimary)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(40)
        }
    }
}
