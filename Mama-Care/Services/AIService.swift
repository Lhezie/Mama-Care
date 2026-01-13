//
//  AIService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 25/11/2025.
//
//

import Foundation
import GoogleGenerativeAI
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
    private var cancellables = Set<AnyCancellable>()
    
    // Injected by MamaCareViewModel
    var currentUserID: UUID?
    
    private init() {
        // Initialize Gemini AI
        if !apiKey.isEmpty {
            print(" Initializing Gemini AI with GoogleGenerativeAI SDK")
            
            // Initialize the GenerativeModel
            // using gemini-1.5-flash which is current fast/efficient model
            model = GenerativeModel(name: "gemini-2.0-flash", apiKey: apiKey)
            
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
        // Note: SDK uses [ModelContent] where parts is [Part]
        chat = model.startChat(history: [
            ModelContent(role: "user", parts: [.text("You are a supportive, empathetic assistant for a maternal health app called MamaCare. Your goal is to provide comforting, non-judgmental support to mothers who might be feeling stressed, anxious, or down.Offer gentle advice, encourage self-care, and always remind them to seek professional help if they are in crisis. Keep responses concise and warm.")]),
            ModelContent(role: "model", parts: [.text("I understand. I am ready to support the mothers of MamaCare with empathy and care.")])
        ])
        messages = []
        error = nil
    }
    
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let chat = chat else {
            error = "Chat service not initialized. Check API Key."
            return
        }
        
        isLoading = true
        error = nil
        
        let scrubbedText = scrubPII(from: text)
        
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        persistMessage(userMessage)
        
        let maxRetries = 3
        var attempt = 0
        var success = false
        
        while attempt <= maxRetries && !success {
            do {
                let response = try await chat.sendMessage(scrubbedText)
                
                if let responseText = response.text {
                    let aiMessage = ChatMessage(content: responseText, isUser: false)
                    messages.append(aiMessage)
                    persistMessage(aiMessage)
                    success = true
                }
            } catch {
                let nsError = error as NSError
                let isRateLimit = error.localizedDescription.contains("429") || 
                                  error.localizedDescription.contains("quota") ||
                                  error.localizedDescription.contains("exhausted")
                
                if isRateLimit && attempt < maxRetries {
                    attempt += 1
                    let delay = Double(attempt) * 1.5
                    print("Retrying attempt \(attempt) in \(delay)s...")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                
                if isRateLimit {
                    self.error = "The AI service is currently busy (high demand). Please try again in 1 minute."
                } else {
                    self.error = "Failed to send message: \(error.localizedDescription)"
                }
                print("AI Error: \(error)")
                break
            }
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
                if let profile = swiftData.fetchUserProfile() { // Simplified for now
                    let entry = ChatEntry.from(message, user: profile)
                    try swiftData.saveChatEntry(entry)
                    
                    // Sync to Firebase if cloud user
                    if profile.storageMode == .cloud, let uid = profile.uid {
                        self.userService.syncChatEntry(uid: uid, entry: entry)
                            .receive(on: DispatchQueue.main)
                            .sink { _ in } receiveValue: { _ in
                                print("Chat entry synced to Firebase")
                            }
                            .store(in: &self.cancellables)
                    }
                }
            } catch {
                print("AIService: Failed to persist message: \(error)")
            }
        }
    }
}
