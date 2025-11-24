//
//  UIComponents.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

// MARK: - UI Components

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FoodItemView: View {
    let name: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            Text(name)
                .font(.caption)
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    var color: Color = .primary
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(color)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ToggleSettingRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
            
            Text(title)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

struct MoodOptionView: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: getIconName(for: mood))
                    .font(.title2)
                    .foregroundColor(getColor(for: mood))
                
                Text(mood.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? getColor(for: mood).opacity(0.2) : Color(.systemGray5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? getColor(for: mood) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIconName(for mood: MoodType) -> String {
        switch mood {
        case .good: return "face.smiling.fill"
        case .okay: return "face.neutral.fill"
        case .notGood: return "face.frown.fill"
        }
    }
    
    private func getColor(for mood: MoodType) -> Color {
        switch mood {
        case .good: return .green
        case .okay: return .orange
        case .notGood: return .red
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.headline)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}



// StorageCard.swift

struct StorageCard: View {
    let option: StorageMode
    let icon: String
    let iconColor: Color
    let title: String
    let points: [ConsentPoint]
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        isSelected ? .mamaCarePrimary : Color.gray.opacity(0.4)
                    )
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(points) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: point.color == .red ? "exclamationmark.circle" : "checkmark.circle")
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .green)
                            .font(.system(size: 16))

                        Text(point.text)
                            .font(.system(size: 15))
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .black)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.mamaCarePrimary : .clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onSelect()
            }
        }
    }
}


// MARK: - Custom Checkbox Toggle Style
public struct MamaCheckboxToggleStyle: ToggleStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? Color.mamaCarePrimaryDark : .gray)
                    .font(.system(size: 18))
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

