import SwiftUI

struct DigitalVaccineCardView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mamaCareGrayLight.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // The Card
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("VACCINATION RECORD")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .tracking(1)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(viewModel.currentUser?.firstName ?? "Mother")'s Record")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color.mamaCarePrimary)
                        
                        // Body
                        VStack(spacing: 20) {
                            if let qrImage = viewModel.generateQRImage() {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            } else {
                                VStack {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 60))
                                        .foregroundColor(.mamaCareTextTertiary)
                                    Text("Generating QR Code...")
                                        .font(.caption)
                                        .foregroundColor(.mamaCareTextSecondary)
                                }
                                .frame(width: 200, height: 200)
                            }
                            
                                VStack(spacing: 12) {
                                InfoRow(label: "Child's Birth Date", value: viewModel.currentUser?.birthDate?.formatted(date: .long, time: .omitted) ?? "N/A")
                                InfoRow(label: "Country", value: viewModel.userCountry)
                                InfoRow(label: "Completed", value: "\(viewModel.vaccineSchedule.filter { $0.status == .completed }.count) Vaccines")
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .background(Color.white)
                    }
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding()
                    
                    VStack(spacing: 8) {
                        Text("Secure Digital Record")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text("Scan this code at a clinic to share your child's immunization record securely.")
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Digital Vaccine Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.mamaCareTextSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.mamaCareTextPrimary)
        }
    }
}

#Preview {
    DigitalVaccineCardView()
        .environmentObject(MamaCareViewModel())
}
