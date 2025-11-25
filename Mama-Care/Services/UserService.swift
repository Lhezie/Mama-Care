//
//  UserService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Combine

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Create User Profile
    func createUserProfile(user: User) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
             
             do {
                 try self.db.collection("users").document(user.id.uuidString).setData(from: user) { error in
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
    
    // Overload to specify document ID (Auth UID)
    func createUserProfile(user: User, uid: String) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            do {
                try self.db.collection("users").document(uid).setData(from: user) { error in
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
    
    // MARK: - Fetch User Profile
    func fetchUser(uid: String) -> Future<User, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    promise(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                    return
                }
                
                do {
                    let user = try snapshot.data(as: User.self)
                    promise(.success(user))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Delete User Data
    func deleteUserData(uid: String) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let userRef = self.db.collection("users").document(uid)
            
            // First, delete all subcollections (e.g., moods)
            userRef.collection("moods").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // Delete all mood documents
                let batch = self.db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    // After deleting subcollections, delete the user document
                    userRef.delete { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
        }
    }
}
