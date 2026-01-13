import Foundation
import Combine
import SwiftData

@MainActor
final class MoodViewModel: ObservableObject {
    @Published var moodCheckIns: [MoodCheckIn] = []
    @Published var saveError: String?
    
    private let authService: AuthService
    private let moodService: MoodService
    private let swiftDataService: SwiftDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = .shared,
         moodService: MoodService = .shared,
         swiftDataService: SwiftDataService = .shared) {
        self.authService = authService
        self.moodService = moodService
        self.swiftDataService = swiftDataService
    }
    
    
    
    func addMoodCheckIn(_ checkIn: MoodCheckIn, for user: User?) {
        // 1. Update local state immediately for UI responsiveness
        moodCheckIns.insert(checkIn, at: 0)
        
        guard let user = user else { return }
        
        // 2. Persist based on Storage Mode
        if user.storageMode == .cloud {
            guard let uid = authService.currentUser?.uid else { return }
            print(" Saving mood to Cloud...")
            moodService.addMood(checkIn, userID: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to save mood to Cloud: \(error.localizedDescription)")
                        self.saveError = "Failed to save to cloud: \(error.localizedDescription)"
                    }
                } receiveValue: {
                    print(" Mood saved to Cloud")
                    self.saveError = nil
                }
                .store(in: &cancellables)
        } else {
            print(" Saving mood locally (SwiftData)...")
            saveMoodsToSwiftData(checkIn)
        }
    }
    
    func fetchMoodCheckIns(for user: User?) {
        guard let user = user else { return }
        
        if user.storageMode == .cloud {
            guard let uid = authService.currentUser?.uid else { return }
            print(" Fetching moods from Cloud...")
            moodService.fetchMoods(userID: uid)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        print(" Failed to fetch moods from Cloud: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] moods in
                    self?.moodCheckIns = moods
                    print(" Fetched \(moods.count) moods from Cloud")
                }
                .store(in: &cancellables)
        } else {
            print(" Loading moods from SwiftData...")
            loadMoodsFromSwiftData()
        }
    }
    
    func exportMoodData() throws -> URL {
        print(" Exporting mood data as CSV...")
        
        guard !moodCheckIns.isEmpty else {
            throw NSError(
                domain: "MoodViewModel",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No mood data to export. Start tracking your moods first!"]
            )
        }
        
        // Date formatters
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        // 1. Create CSV Header
        var csvString = "Date,Time,Mood,Notes\n"
        
        // 2. Add rows
        for mood in moodCheckIns {
            let date = dateFormatter.string(from: mood.date)
            let time = timeFormatter.string(from: mood.date)
            let moodType = mood.moodType.rawValue
            
            // Clean notes to avoid breaking CSV format (remove newlines and escape quotes)
            var notes = mood.notes ?? ""
            notes = notes.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
            notes = "\"\(notes)\"" // Enclose in quotes to handle commas
            
            let row = "\(date),\(time),\(moodType),\(notes)\n"
            csvString.append(row)
        }
        
        // 3. Save to temporary directory
        let fileName = "MamaCare_Mood_History.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            print(" Mood data exported to: \(tempURL.path)")
            return tempURL
        } catch {
            throw NSError(
                domain: "MoodViewModel",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Unable to create CSV file. Please try again."]
            )
        }
    }
    
    //  SwiftData persistence
    
    private func saveMoodsToSwiftData(_ checkIn: MoodCheckIn) {
        guard let userProfile = swiftDataService.fetchUserProfile() else {
            print(" No user profile found in SwiftData")
            return
        }
        
        let entry = MoodEntry.from(checkIn, user: userProfile)
        
        do {
            try swiftDataService.saveMoodEntry(entry)
            print(" Mood saved to SwiftData (encrypted)")
            saveError = nil
        } catch {
            print(" Failed to save mood to SwiftData: \(error)")
            saveError = "Failed to save locally: \(error.localizedDescription)"
        }
    }
    
    private func loadMoodsFromSwiftData() {
        guard let userProfile = swiftDataService.fetchUserProfile() else {
            print(" No user profile found in SwiftData")
            return
        }
        
        let entries = swiftDataService.fetchMoodEntries(for: userProfile)
        moodCheckIns = entries.map { $0.toMoodCheckIn() }
        print(" Loaded \(moodCheckIns.count) moods from SwiftData")
    }
}
