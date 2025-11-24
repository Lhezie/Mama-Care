import SwiftUI

struct DateCaptureView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    var onNext: () -> Void
    var onBack: () -> Void
    
    @EnvironmentObject var viewModel: MamaCareViewModel

    @State private var selectedDate = Date()
    @State private var showingError = false
    @State private var errorMessage = ""

    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()

        switch onboardingVM.user.userType {
        case .pregnant:
            let maxDate = calendar.date(byAdding: .day, value: 42 * 7, to: today)!
            return today...maxDate
        case .hasChild:
            let minDate = calendar.date(byAdding: .year, value: -5, to: today)!
            return minDate...today
        case .none:
            return today...today
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(getTitle())
                    .font(.title2)
                    .fontWeight(.bold)

                Text(getSubtitle())
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            .padding(.horizontal, 40)

            Spacer().frame(height: 40)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color(hex: "#00BBA7"))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(getTitle())
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)

                        Text(getSubtitle())
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5B5B5B"))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(getLabel())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)

                    DatePicker("", selection: $selectedDate, in: dateRange, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }

                if showingError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(hex: "#E8FCF9"))
            .cornerRadius(20)
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 16) {
                Button("Back") {
                    onBack()
                }
                .buttonStyle(SecondaryButtonStyle())

                Button("Continue") {
                    validateAndContinue()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "#E8FCF9").ignoresSafeArea())
    }

    private func getTitle() -> String {
        switch onboardingVM.user.userType {
        case .pregnant: return "When is your Expected Delivery Date (EDD)?"
        case .hasChild: return "What is your child's date of birth?"
        case .none: return "Select Date"
        }
    }

    private func getSubtitle() -> String {
        switch onboardingVM.user.userType {
        case .pregnant:
            return "This helps us provide weekly pregnancy guidance and calculate your baby's vaccine schedule"
        case .hasChild:
            return "This helps us provide age-appropriate postpartum support and track your baby's vaccine schedule"
        case .none:
            return "Please select a date"
        }
    }

    private func getLabel() -> String {
        switch onboardingVM.user.userType {
        case .pregnant: return "Expected Delivery Date"
        case .hasChild: return "Birth Date"
        case .none: return "Date"
        }
    }

    private func validateAndContinue() {
        let calendar = Calendar.current
        let today = Date()

        switch onboardingVM.user.userType {
        case .pregnant:
            let maxDate = calendar.date(byAdding: .day, value: 42 * 7, to: today)!
            if selectedDate > maxDate {
                errorMessage = "EDD should be within the next 42 weeks"
                showingError = true
                return
            }
            onboardingVM.user.expectedDeliveryDate = selectedDate

        case .hasChild:
            if selectedDate > today {
                errorMessage = "Please choose a date that isn't in the future"
                showingError = true
                return
            }
            onboardingVM.user.birthDate = selectedDate

        case .none:
            return
        }

        showingError = false
        onNext()
    }
}


