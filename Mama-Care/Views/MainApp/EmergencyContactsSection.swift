//
//  EmergencyContactsSection.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 18/11/2025.
//



import SwiftUI

struct EmergencyContactsSection: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var showingAddSheet = false
    @State private var editingContact: EmergencyContact? = nil
    var showHeader: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            if showHeader {
                // Header is now just the title and subtitle in the design, centered?
                // Image 1 shows "Emergency Contacts" title, subtitle below, then the "Add Contact" button.
                // The current header has title left, add button right.
                // The design in Image 1 shows:
                // [Red Shield Icon]
                // "Emergency Contacts" (Title)
                // "Add trusted contacts..." (Subtitle)
                // [Add Emergency Contact Button] (Full width outline)
                // [Empty State Card]
                
                // Wait, if I change the header here, it changes for Main App too.
                // The Main App might expect the old header (Title + Plus button).
                // But user said "Emergency Contact Screen... replica of my figma file".
                // I will implement the Figma design here.
                
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF2D55")) // Red/Pink
                            .frame(width: 60, height: 60)
                        Image(systemName: "shield.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Text("Emergency Contacts")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Add trusted contacts who can be reached\nin case of emergency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            }

            // Add Contact Button (Outline Style)
            Button {
                editingContact = nil
                showingAddSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Emergency Contact")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mamaCarePrimary, lineWidth: 1)
                )
            }
            .padding(.horizontal)

            if viewModel.emergencyContacts.isEmpty {
                emptyState
            } else {
                contactList
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEmergencyContactView(
                contactToEdit: $editingContact,
                onSave: { contact in
                    if let index = viewModel.emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
                        viewModel.emergencyContacts[index] = contact
                    } else {
                        viewModel.addEmergencyContact(contact)
                    }
                }
            )
            .environmentObject(viewModel)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield")
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.3))
            
            Text("No contacts added yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add at least one emergency contact for\nyour safety, or skip and add them later\nin Settings.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Contacts list
//                        } label: {
//                            Label("Edit", systemImage: "pencil")
//                        }
//                        .tint(.blue)
//                    }
//            }
//        }
//        .padding(.horizontal)
//    }
//}


    private var contactList: some View {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.emergencyContacts) { contact in
                    EmergencyContactRow(contact: contact)
                        .swipeActions(edge: .trailing) {
                            
                            // DELETE
                            Button(role: .destructive) {
                                viewModel.deleteEmergencyContact(contact)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            // EDIT
                            Button {
                                editingContact = contact
                                showingAddSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
