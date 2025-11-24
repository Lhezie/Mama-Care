//
//  EmergencyContactRow.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 04/11/2025.
//


import SwiftUI

struct EmergencyContactRow: View {
    let contact: EmergencyContact

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Name + Relationship badge
            HStack(alignment: .center) {
                Text(contact.name)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Text(contact.relationship)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.mamaCarePrimary.opacity(0.1))
                    .foregroundColor(Color.mamaCarePrimary)
                    .clipShape(Capsule())
            }

            // Phone
            if !contact.phoneNumber.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)
                    Text(contact.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }

            // Email
            if !contact.email.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    Text(contact.email)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
    }
}
