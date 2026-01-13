
import XCTest
@testable import Mama_Care

final class MamaCareTests: XCTestCase {

    //  Date Helper Tests (Logic Verification)
    
    func testPregnancyWeekCalculation() {
        // Given: A user with an EDD 20 weeks from now
        let today = Date()
        let calendar = Calendar.current
        guard let edd = calendar.date(byAdding: .weekOfYear, value: 20, to: today) else {
            XCTFail("Could not create EDD date")
            return
        }
        
        // When: We calculate the current pregnancy week
        // Logic: 40 weeks total - 20 weeks remaining = 20 weeks pregnant
        let week = MamaCareDateHelper.pregnancyWeek(edd: edd, on: today)
        
        // Then: The result should be approximately 20 (or 21 depending on rounding logic)
        XCTAssertTrue(week >= 19 && week <= 21, "Pregnancy week should be around 20, got \(week)")
    }
    
    func testPostpartumDaysCalculation() {
        // Given: A user who gave birth 10 days ago
        let today = Date()
        let calendar = Calendar.current
        guard let birthDate = calendar.date(byAdding: .day, value: -10, to: today) else {
            XCTFail("Could not create birth date")
            return
        }
        
        // When: We calculate days postpartum
        let days = MamaCareDateHelper.daysSinceBirth(birthDate: birthDate, on: today)
        
        // Then: Result should be 10
        XCTAssertEqual(days, 10, "Days postpartum should be 10")
    }

    //  Encryption Tests (Security Verification)
    
    func testEncryptionAndDecryptionFlow() {
        // Given: A sensitive string
        let originalText = "My Secret Medical Data"
        guard let data = originalText.data(using: .utf8) else {
            XCTFail("Could not convert string to data")
            return
        }
        
        // When: We encrypt it
        let service = EncryptionService.shared
        guard let encryptedData = service.encrypt(data: data) else {
            XCTFail("Encryption failed")
            return
        }
        
        // Then: The encrypted data should NOT match the original data
        XCTAssertNotEqual(encryptedData, data, "Ciphertext must be different from plaintext")
        
        // And When: We decrypt it back
        guard let decryptedData = service.decrypt(data: encryptedData) else {
            XCTFail("Decryption failed")
            return
        }
        
        let decryptedText = String(data: decryptedData, encoding: .utf8)
        
        // Then: It should match the original text exactly
        XCTAssertEqual(decryptedText, originalText, "Decrypted text must match original")
    }
}
