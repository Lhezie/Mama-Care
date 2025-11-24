//
//  VaccineScheduleView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct VaccineScheduleView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedFilter: VaccineFilter = .all
    
    enum VaccineFilter: String, CaseIterable {
        case all = "All"
        case upcoming = "Upcoming"
        case due = "Due"
        case overdue = "Overdue"
        case completed = "Completed"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vaccine Schedule")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("Track your baby's immunization progress")
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                    }
                    
                    Spacer()
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(VaccineFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            
            // Vaccine List
            ScrollView {
                if filteredVaccines.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.mamaCareTextTertiary)
                        
                        Text("No vaccines found")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("Try adjusting your filters or check back later")
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredVaccines) { vaccine in
                            VaccineCard(vaccine: vaccine)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.mamaCareGrayLight)
        }
        .onAppear {
            // Load vaccines from JSON when view appears
            viewModel.loadVaccinesFromJSON()
        }
    }
    
    var filteredVaccines: [VaccineItem] {
        let allVaccines = viewModel.vaccineSchedule
        
        switch selectedFilter {
        case .all:
            return allVaccines
        case .upcoming:
            return allVaccines.filter { $0.status == .upcoming }
        case .due:
            return allVaccines.filter { $0.status == .due }
        case .overdue:
            return allVaccines.filter { $0.status == .overdue }
        case .completed:
            return allVaccines.filter { $0.status == .completed }
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .mamaCareTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .mamaCarePrimary : Color.mamaCareGrayMedium)
                .cornerRadius(20)
        }
    }
}

struct VaccineCard: View {
    let vaccine: VaccineItem
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "syringe.fill")
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vaccine.name)
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Spacer()
                        
                        StatusBadge(status: vaccine.status)
                    }
                    
                    Text(vaccine.ageRange)
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                }
            }
            
            Text(vaccine.description)
                .font(.subheadline)
                .foregroundColor(.mamaCareTextDark)
                .lineLimit(2)
            
            if let dueDate = vaccine.dueDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                    Text("Due: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                }
            }
            
            // Action Button
            if vaccine.status != .completed && vaccine.status != .upcoming {
                Button {
                    viewModel.markVaccineAsCompleted(vaccine)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark as Done")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mamaCarePrimary)
                    .cornerRadius(12)
                }
            } else if vaccine.status == .completed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mamaCareCompleted)
                    Text("Completed on \(vaccine.completedDate ?? Date(), style: .date)")
                        .font(.caption)
                        .foregroundColor(.mamaCareCompleted)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mamaCareCompletedBg)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    var statusColor: Color {
        switch vaccine.status {
        case .upcoming:
            return .mamaCareUpcoming // Blue
        case .due:
            return .mamaCareDue // Orange
        case .overdue:
            return .mamaCareOverdue // Red
        case .completed:
            return .mamaCareCompleted // Green
        }
    }
}

struct StatusBadge: View {
    let status: VaccineStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(12)
    }
    
    var textColor: Color {
        switch status {
        case .upcoming:
            return .mamaCareUpcoming
        case .due:
            return .mamaCareDue
        case .overdue:
            return .mamaCareOverdue
        case .completed:
            return .mamaCareCompleted
        }
    }
    
    var backgroundColor: Color {
        switch status {
        case .upcoming:
            return .mamaCareUpcomingBg
        case .due:
            return .mamaCareDueBg
        case .overdue:
            return .mamaCareOverdueBg
        case .completed:
            return .mamaCareCompletedBg
        }
    }
}

// MARK: - Preview
#Preview {
    VaccineScheduleView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Sarah",
                lastName: "Johnson",
                email: "sarah@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .hasChild,
                birthDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())
            )
            return viewModel
        }())
}
