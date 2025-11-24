//
//  AuthService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Sign Up
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
    
    // MARK: - Sign In
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
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Current User
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
