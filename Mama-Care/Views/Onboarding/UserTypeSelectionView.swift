
import SwiftUI

struct UserTypeSelectionView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    var onNext: () -> Void
    var onBack: () -> Void

    @EnvironmentObject var viewModel: MamaCareViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            contentSection
            
            Spacer()
            
            navigationButtons
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(hex: "F0FDFA").ignoresSafeArea())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Tell Us About You")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.mamaCareTextPrimary)
            
            Text("Help us personalize your MamaCare experience")
                .font(.subheadline)
                .foregroundColor(.mamaCareTextSecondary)
        }
        .padding(.top, 40)
        .padding(.bottom, 32)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Which describes you best?")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                userTypeCards
            }
        }
    }
    
    // MARK: - User Type Cards
    private var userTypeCards: some View {
        VStack(spacing: 16) {
            UserTypeCard(
                emoji: "🤰",
                title: "I am pregnant",
                description: "Track your pregnancy journey, mood,\nand prepare for your baby's arrival",
                isSelected: onboardingVM.user.userType == .pregnant,
                backgroundColor: .mamaCarePinkLight
            ) {
                onboardingVM.user.userType = .pregnant
            }
            
            UserTypeCard(
                emoji: "👶",
                title: "I have a child",
                description: "Postpartum support, baby's\nvaccine schedule, and growth\ntracking",
                isSelected: onboardingVM.user.userType == .hasChild,
                backgroundColor: .mamaCareUpcomingBg
            ) {
                onboardingVM.user.userType = .hasChild
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            Button {
                onBack()
            } label: {
                Text("Back")
                .font(.headline)
                .foregroundColor(.mamaCareTextSecondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.mamaCareGrayBorder, lineWidth: 1)
                )
            }
            
            Button {
                if onboardingVM.user.userType != nil {
                    // Update the main view model as well if needed, though OnboardingFlow usually handles the final sync.
                    // But for safety/consistency with previous logic:
                    viewModel.currentUser?.userType = onboardingVM.user.userType
                    onNext()
                }
            } label: {
                HStack {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mamaCarePrimary)
                .cornerRadius(12)
            }
            .disabled(onboardingVM.user.userType == nil)
            .opacity(onboardingVM.user.userType == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}

struct UserTypeCard: View {
    let emoji: String
    let title: String
    let description: String
    let isSelected: Bool
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.mamaCarePink : backgroundColor)
                        .frame(width: 100, height: 100)
                    
                    Text(emoji)
                        .font(.system(size: 48))
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.mamaCareTextPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.mamaCarePink : Color.mamaCareGrayBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
