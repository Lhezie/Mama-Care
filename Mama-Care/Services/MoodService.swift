//
//  MoodService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
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
            do {
                let _ = try self.db.collection("users").document(userID).collection("moods").addDocument(from: mood) { error in
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
                    
                    do {
                        let moods = try documents.compactMap { try $0.data(as: MoodCheckIn.self) }
                        promise(.success(moods))
                    } catch {
                        promise(.failure(error))
                    }
                }
        }
    }
}
