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
            
            // Ensure we have a user ID (usually from Auth)
            // If the User struct doesn't store the Auth UID directly, we might need to pass it or rely on the ID being set.
            // Assuming User.id is UUID, but for Firebase we usually use the Auth UID as the document ID.
            // We'll need to handle this mapping. For now, let's assume we use the User.id.uuidString or a passed UID.
            // Ideally, we should use the Auth UID.
            
            // Let's assume we want to store it under the user's ID.
            // However, the User model uses UUID.
            // Strategy: We will use the User struct as is, but when saving to Firestore,
            // we should probably use the Auth UID as the document ID for easy retrieval.
            
            // For this implementation, I'll accept the User object and save it.
            // But I need the Auth UID to key it correctly.
            // I'll modify this to take the uid explicitly.
             
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
}
