//
//  EncryptionService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import CryptoKit
import Security

class EncryptionService {
    static let shared = EncryptionService()
    private let keyTag = "com.mamacare.encryptionKey"
    
    private init() {}
    
    // MARK: - Key Management
    
    private func getSymmetricKey() -> SymmetricKey {
        // Check if key exists in Keychain
        if let keyData = readKeyFromKeychain() {
            return SymmetricKey(data: keyData)
        }
        
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        saveKeyToKeychain(key: newKey)
        return newKey
    }
    
    private func saveKeyToKeychain(key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecValueData as String: keyData
        ]
        
        // Delete any existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("❌ Failed to save encryption key to Keychain: \(status)")
        }
    }
    
    private func readKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag.data(using: .utf8)!,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            return item as? Data
        }
        return nil
    }
    
    // MARK: - Encryption / Decryption
    
    func encrypt(data: Data) -> Data? {
        do {
            let key = getSymmetricKey()
            let sealedBox = try ChaChaPoly.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("❌ Encryption failed: \(error)")
            return nil
        }
    }
    
    func decrypt(data: Data) -> Data? {
        do {
            let key = getSymmetricKey()
            let sealedBox = try ChaChaPoly.SealedBox(combined: data)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
            return decryptedData
        } catch {
            print("❌ Decryption failed: \(error)")
            return nil
        }
    }
}
