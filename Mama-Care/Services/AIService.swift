//
//  AIService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 25/11/2025.
//

import Foundation
import FirebaseAILogic
import Combine

@MainActor
class AIService: ObservableObject {
    static let shared = AIService()
    
    // Fetched from Configuration.swift
    private let apiKey = Configuration.geminiAPIKey
    
    private var model: GenerativeModel?
    private var chat: Chat?
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let userService = UserService.shared
    
    private init() {
        // Initialize Firebase AI with Gemini Developer API (FREE)
       
        if !apiKey.isEmpty {
            print(" Initializing Firebase AI with Gemini Developer API (free tier)")
            
            // Initialize the Gemini 
            let ai = FirebaseAI.firebaseAI(backend: .googleAI())
            
            // Create a GenerativeModel
            model = ai.generativeModel(modelName: "gemini-2.5-flash")
            startNewChat()
        } else {
            print("Gemini API Key not configured")
            error = "API Key missing"
        }
    }
    
    func startNewChat() {
        guard let model = model else {
            error = "Model not initialized"
            return
        }
        
        // Define the persona and system instructions via history
        chat = model.startChat(history: [
            ModelContent(role: "user", parts: "You are a supportive, empathetic assistant for a maternal health app called MamaCare. Your goal is to provide comforting, non-judgmental support to mothers who might be feeling stressed, anxious, or down.Offer gentle advice, encourage self-care, and always remind them to seek professional help if they are in crisis. Keep responses concise and warm."),
            ModelContent(role: "model", parts: "I understand. I am ready to support the mothers of MamaCare with empathy and care.")
        ])
        messages = []
        error = nil
    }
    
    // Injected by MamaCareViewModel
    var currentUserID: UUID?
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let chat = chat else {
            error = "Chat service not initialized. Check API Key."
            return
        }
        
        isLoading = true
        error = nil
        
        // Scrub PII for privacy (Email & Phone)
        let scrubbedText = scrubPII(from: text)
        
        // Add user message to UI immediately (show original to user)
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        // Persist user message
        persistMessage(userMessage)
        
        do {
            // Send scrubbed text to AI
            let response = try await chat.sendMessage(scrubbedText)
            if let responseText = response.text {
                let aiMessage = ChatMessage(content: responseText, isUser: false)
                messages.append(aiMessage)
                
                // Persist AI response
                persistMessage(aiMessage)
            }
        } catch {
            self.error = "Failed to send message: \(error.localizedDescription)"
            print("AI Error: \(error)")
        }
        
        isLoading = false
    }
    
    //  Privacy (PII Scrubbing)
    
    private func scrubPII(from text: String) -> String {
        var scrubbed = text
        // Redact Emails
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let regex = try? NSRegularExpression(pattern: emailPattern, options: .caseInsensitive) {
            scrubbed = regex.stringByReplacingMatches(in: scrubbed, range: NSRange(location: 0, length: scrubbed.utf16.count), withTemplate: "[EMAIL REDACTED]")
        }
        // Redact Phone Numbers (Basic 11 digits)
        let phonePattern = "[0-9]{11}"
        if let regex = try? NSRegularExpression(pattern: phonePattern) {
            scrubbed = regex.stringByReplacingMatches(in: scrubbed, range: NSRange(location: 0, length: scrubbed.utf16.count), withTemplate: "[PHONE REDACTED]")
        }
        return scrubbed
    }
    
    private func persistMessage(_ message: ChatMessage) {
        guard let userID = currentUserID else {
            print("AIService: No userID available, skipping persistence")
            return
        }
        
        Task {
            do {
                let swiftData = SwiftDataService.shared
                if let profile = swiftData.fetchUserProfile() { // Simplified for now, MamaCareViewModel handles logic
                    let entry = ChatEntry.from(message, user: profile)
                    try swiftData.saveChatEntry(entry)
                    
                    // Sync to Firebase if cloud user
                    if profile.storageMode == .cloud, let uid = profile.uid {
                        self.userService.syncChatEntry(uid: uid, entry: entry)
                            .receive(on: DispatchQueue.main)
                            .sink { _ in } receiveValue: { _ in
                                print("Chat entry synced to Firebase")
                            }
                            .store(in: &self.cancellables) // Need cancellables
                    }
                }
            } catch {
                print("AIService: Failed to persist message: \(error)")
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
}
