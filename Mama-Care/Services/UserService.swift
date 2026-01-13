//
//  UserService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Combine

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    //  Create User Profile
    func createUserProfile(user: User) -> Future<Void, Error> {
        return createUserProfile(user: user, uid: user.id.uuidString)
    } 
    
    // Overload to specify document ID (Auth UID)
    func createUserProfile(user: User, uid: String) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            // 1. Encrypt PII Fields
            guard let encFirstName = EncryptionService.shared.encryptString(user.firstName),
                  let encLastName = EncryptionService.shared.encryptString(user.lastName),
                  let encEmail = EncryptionService.shared.encryptString(user.email),
                  let encPhone = EncryptionService.shared.encryptString(user.mobileNumber) else {
                promise(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: 
                "Encryption failed for user data"])))
                return
            }
            
            // 2. Encrypt Contacts
            let encContacts: [EncryptedContactDTO] = user.emergencyContacts.compactMap { contact in
                guard let cName = EncryptionService.shared.encryptString(contact.name),
                      let cRel = EncryptionService.shared.encryptString(contact.relationship),
                      let cPhone = EncryptionService.shared.encryptString(contact.phoneNumber),
                      let cEmail = EncryptionService.shared.encryptString(contact.email) else { return nil }
                
                return EncryptedContactDTO(
                    id: contact.id.uuidString,
                    name: cName,
                    relationship: cRel,
                    phoneNumber: cPhone,
                    email: cEmail
                )
            }
            
            // 3. Create DTO
            let encryptedUser = EncryptedUserFirestoreData(
                id: user.id.uuidString,
                firstName: encFirstName,
                lastName: encLastName,
                email: encEmail,
                mobileNumber: encPhone,
                country: user.country,
                userType: user.userType?.rawValue,
                expectedDeliveryDate: user.expectedDeliveryDate,
                birthDate: user.birthDate,
                storageMode: user.storageMode.rawValue,
                privacyAcceptedAt: user.privacyAcceptedAt,
                notificationsWanted: user.notificationsWanted,
                checkInTimes: user.checkInTimes,
                isPremium: user.isPremium,
                escalationEnabled: user.escalationEnabled,
                emergencyContacts: encContacts
            )
            
            // 4. Save to Firestore
            do {
                try self.db.collection("users").document(uid).setData(from: encryptedUser) { error in
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
    
    //  Fetch User Profile
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
                
                // Attempt to decode as Encrypted Data First
                do {
                    let encUser = try snapshot.data(as: EncryptedUserFirestoreData.self)
                    
                    // Decrypt Fields
                    guard let firstName = EncryptionService.shared.decryptString(encUser.firstName),
                          let lastName = EncryptionService.shared.decryptString(encUser.lastName),
                          let email = EncryptionService.shared.decryptString(encUser.email),
                          let phone = EncryptionService.shared.decryptString(encUser.mobileNumber) else {
                        throw NSError(domain: "UserService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Decryption failed for user data"])
                    }
                    
                    // Decrypt Contacts
                    let contacts: [EmergencyContact] = encUser.emergencyContacts.compactMap { ec in
                        guard let cName = EncryptionService.shared.decryptString(ec.name!), // Force unwrap DTO optionals if schema guarantees them, or use safer default
                              let cRel = EncryptionService.shared.decryptString(ec.relationship!),
                              let cPhone = EncryptionService.shared.decryptString(ec.phoneNumber!),
                              let cEmail = EncryptionService.shared.decryptString(ec.email!) else { return nil }
                        
                        var contact = EmergencyContact(name: cName, relationship: cRel, phoneNumber: cPhone, email: cEmail)
                        if let uuid = UUID(uuidString: ec.id) { contact.id = uuid }
                        return contact
                    }
                    
                    // Reconstruct User Object
                    var user = User(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        country: encUser.country,
                        mobileNumber: phone,
                        userType: UserType(rawValue: encUser.userType ?? ""),
                        expectedDeliveryDate: encUser.expectedDeliveryDate,
                        birthDate: encUser.birthDate
                    )
                    user.storageMode = StorageMode(rawValue: encUser.storageMode) ?? .deviceOnly
                    user.privacyAcceptedAt = encUser.privacyAcceptedAt
                    user.notificationsWanted = encUser.notificationsWanted
                    user.checkInTimes = encUser.checkInTimes
                    user.isPremium = encUser.isPremium
                    user.escalationEnabled = encUser.escalationEnabled
                    user.emergencyContacts = contacts
                    if let uuid = UUID(uuidString: encUser.id) { user.id = uuid }
                    
                    promise(.success(user))
                    
                } catch {
                    // FALLBACK: Try decoding as Plaintext (Legacy Data)
                    // This handles the user's concern about existing data.
                    do {
                        print("Encrypted fetch failed, attempting legacy fetch: \(error)")
                        let user = try snapshot.data(as: User.self)
                        promise(.success(user))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    //  Delete User Data
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

    func updateVaccineRecord(uid: String, record: VaccineRecord) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            do {
               
                // Update the vaccine record in Firestore
                let data: [String: Any] = [
                    "code": record.code,
                    "completedDate": record.completedDate ?? Date(),
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                // Used to determine the "late write" 
                try self.db.collection("users").document(uid)
                    .collection("vaccines").document(record.code)
                    .setData(data, merge: true) { error in
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
    
    //  Fetch Vaccines
    func fetchVaccineRecords(uid: String) -> Future<[VaccineRecord], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.db.collection("users").document(uid)
                .collection("vaccines")
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let records = documents.compactMap { doc -> VaccineRecord? in
                        let data = doc.data()
                        guard let code = data["code"] as? String else { return nil }
                        
                        let timestamp = data["completedDate"] as? Timestamp
                        let completedDate = timestamp?.dateValue() ?? Date()
                        
                        // Note: We don't attach the UserProfile here as this is a DTO-like object
                        // The calling ViewModel will need to handle swiftData context if saving
                        return VaccineRecord(code: code, completedDate: completedDate)
                    }
                    
                    promise(.success(records))
                }
        }
    }
    
    //  Chat Session Sync
    
    func syncChatEntry(uid: String, entry: ChatEntry) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let data: [String: Any] = [
                "id": entry.id.uuidString,
                "date": entry.date,
                "isUser": entry.isUser,
                "encryptedContent": entry.encryptedContent ?? Data(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            self.db.collection("users").document(uid)
                .collection("chats").document(entry.id.uuidString)
                .setData(data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
    }
    
    func fetchChatHistory(uid: String) -> Future<[ChatMessage], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.db.collection("users").document(uid)
                .collection("chats")
                .order(by: "date", descending: false)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let messages = documents.compactMap { doc -> ChatMessage? in
                        let data = doc.data()
                        guard let idString = data["id"] as? String,
                              let id = UUID(uuidString: idString),
                              let isUser = data["isUser"] as? Bool,
                              let encryptedData = data["encryptedContent"] as? Data,
                              let timestamp = data["date"] as? Timestamp else { return nil }
                        
                        //  return a DTO here; the ViewModel will decrypt
                        if let content = EncryptionService.shared.decryptString(encryptedData) {
                            return ChatMessage(id: id, content: content, isUser: isUser, timestamp: timestamp.dateValue())
                        }
                        return nil
                    }
                    
                    promise(.success(messages))
                }
        }
    }
}
