//
//  PrimaryButtonStyle.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//


// Update Views/Components/CustomStyles.swift
import SwiftUI

// MARK: - Custom Button Styles with your gradient
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.mamaCareGradient)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color.mamaCarePrimary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.mamaCarePrimary.opacity(0.1))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}


struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
