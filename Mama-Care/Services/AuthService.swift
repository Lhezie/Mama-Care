//
//  AuthService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService {
    static let shared = AuthService()
    
    @Published var user: FirebaseAuth.User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Listen for auth state changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            if let user = user {
                print(" AuthService: User state changed -> Logged in as \(user.uid)")
            } else {
                print(" AuthService: User state changed -> Logged out")
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Sign Up
    func signUp(email: String, password: String) -> Future<AuthDataResult, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
    }
    
    // Sign In
    func signIn(email: String, password: String) -> Future<AuthDataResult, Error> {
        return Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
    }
    
    //  Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    //  Password Reset
    func sendPasswordResetEmail(email: String) -> Future<Void, Error> {
        return Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    //  Delete Account
    func deleteAccount() -> Future<Void, Error> {
        return Future { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
                return
            }
            
            user.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    //  Current User
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
