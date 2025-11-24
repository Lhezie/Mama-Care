//
//  Colors.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

// Add this to a new file: Views/DesignSystem/Colors.swift
import SwiftUI

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - MamaCare Design System Colors
extension Color {
    // MARK: - Primary Colors
    static let mamaCarePrimary = Color(hex: "00BBA7")
    static let mamaCarePrimaryBg = Color(hex: "F0FDFA")
    static let mamaCarePrimaryDark = Color(hex: "009966")
    static let mamaCareAccent = Color(hex: "009689")
    static let mamaCareTeal = Color(hex: "00C4B4")
    static let mamaCareTealDark = Color(hex: "00A88F")
    
    // MARK: - Status Colors
    static let mamaCareError = Color(hex: "FB2C36")
    static let mamaCareSuccess = Color(hex: "008236")
    static let mamaCareWarning = Color(hex: "F59E0B")
    static let mamaCareInfo = Color(hex: "3B82F6")
    
    // MARK: - Vaccine Status Colors
    static let mamaCareUpcoming = Color(hex: "3B82F6")      // Blue
    static let mamaCareUpcomingBg = Color(hex: "DBEAFE")    // Light Blue
    static let mamaCareDue = Color(hex: "F59E0B")           // Orange
    static let mamaCareDueBg = Color(hex: "FEF3C7")         // Light Orange
    static let mamaCareOverdue = Color(hex: "EF4444")       // Red
    static let mamaCareOverdueBg = Color(hex: "FEE2E2")     // Light Red
    static let mamaCareCompleted = Color(hex: "10B981")     // Green
    static let mamaCareCompletedBg = Color(hex: "D1FAE5")   // Light Green
    
    // MARK: - Text Colors
    static let mamaCareTextPrimary = Color(hex: "1F2937")   // Dark Gray
    static let mamaCareTextSecondary = Color(hex: "6B7280") // Medium Gray
    static let mamaCareTextTertiary = Color(hex: "9CA3AF") // Light Gray
    static let mamaCareTextDark = Color(hex: "4B5563")      // Darker Gray
    
    // MARK: - Background Colors
    static let mamaCareGrayBackground = Color(hex: "F3F3F5")
    static let mamaCareGrayLight = Color(hex: "F9FAFB")
    static let mamaCareGrayMedium = Color(hex: "F3F4F6")
    static let mamaCareGrayBorder = Color(hex: "E5E7EB")
    
    // MARK: - Icon Background Colors
    static let mamaCareIconBlue = Color(hex: "D0E8FF")
    static let mamaCareIconPurple = Color(hex: "F3E8FF")
    
    // MARK: - Accent Colors
    static let mamaCarePink = Color(hex: "EC4899")
    static let mamaCarePinkLight = Color(hex: "FCE7F3")
    static let mamaCarePurple = Color(hex: "8B5CF6")
    static let mamaCareBlue = Color(hex: "3B82F6")
    static let mamaCareOrange = Color(hex: "F97316")
    static let mamaCareMagenta = Color(hex: "D946EF")
    static let mamaCareRed = Color(hex: "EF4444")
    static let mamaCareRedLight = Color(hex: "FEF2F2")
    static let mamaCareOrangeLight = Color(hex: "FFF7ED")
    static let mamaCarePurpleLight = Color(hex: "FDF4FF")
    static let mamaCareDarkGreen = Color(hex: "004D40")
    
    // MARK: - Gradients
    static let mamaCareGradient = LinearGradient(
        gradient: Gradient(colors: [mamaCarePrimary, mamaCarePrimaryDark]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let mamaCareTealGradient = LinearGradient(
        gradient: Gradient(colors: [mamaCareTeal, mamaCareTealDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let mamaCarePurpleGradient = LinearGradient(
        gradient: Gradient(colors: [mamaCareBlue, mamaCarePurple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
