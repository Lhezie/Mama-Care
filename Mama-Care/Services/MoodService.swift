//
//  MoodService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Combine

class MoodService {
    static let shared = MoodService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Add Mood
    func addMood(_ mood: MoodCheckIn, userID: String) -> Future<Void, Error> {
        return Future { promise in
            // Encrypt Notes
            var encryptedNotes: Data? = nil
            if let notes = mood.notes, !notes.isEmpty {
                encryptedNotes = EncryptionService.shared.encryptString(notes)
            }
            
            let moodDTO = EncryptedMoodDTO(
                id: mood.id.uuidString,
                date: mood.date,
                moodType: mood.moodType.rawValue,
                encryptedNotes: encryptedNotes
            )
            
            do {
                let _ = try self.db.collection("users").document(userID).collection("moods").addDocument(from: moodDTO) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Moods
    func fetchMoods(userID: String) -> Future<[MoodCheckIn], Error> {
        return Future { promise in
            self.db.collection("users").document(userID).collection("moods")
                .order(by: "date", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    var moods: [MoodCheckIn] = []
                    
                    for doc in documents {
                        // Try Encrypted DTO first
                        if let dto = try? doc.data(as: EncryptedMoodDTO.self) {
                            var notes: String? = nil
                            if let encNotes = dto.encryptedNotes {
                                notes = EncryptionService.shared.decryptString(encNotes)
                            }
                            
                            if let moodType = MoodType(rawValue: dto.moodType) {
                                var mood = MoodCheckIn(date: dto.date, moodType: moodType, notes: notes)
                                if let uuid = UUID(uuidString: dto.id) { mood.id = uuid }
                                moods.append(mood)
                            }
                        }
                        // Fallback: Try Legacy (Plaintext)
                        else if let legacy = try? doc.data(as: MoodCheckIn.self) {
                            moods.append(legacy)
                        }
                    }
                    
                    promise(.success(moods))
                }
        }
    }
}
