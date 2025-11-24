//
//  SplashScreenView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    var onFinish: () -> Void
    
    var body: some View {
        ZStack {
            // Teal Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo with Heart Icon
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.mamaCarePrimary)
                    
                    // Star Icon
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.mamaCareDue)
                        .offset(x: 50, y: -40)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // App Name and Tagline
                VStack(spacing: 12) {
                    Text("MamaCare")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your Pregnancy & Child Health\nCompanion")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Loading Dots
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimating = true
            // Call onFinish after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onFinish()
            }
        }
    }
}



//import SwiftUI
//
//struct SplashScreenView: View {
//    @State private var animate = false
//    @State private var showNext = false
//
//    var onFinish: () -> Void
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655),
//                    Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4)
//                ]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 16) {
//                Spacer()
//
//                Image("mamacare_logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 160, height: 160)
//                    .opacity(animate ? 1 : 0)
//                    .scaleEffect(animate ? 1 : 0.8)
//                    .animation(.easeOut(duration: 1.2), value: animate)
//
//                Text("MamaCare")
//                    .font(.system(size: 34, weight: .bold, design: .rounded))
//                    .foregroundColor(Color(.sRGB, red: 0.651, green: 0.294, blue: 0.165))
//                    .opacity(animate ? 1 : 0)
//                    .animation(.easeIn(duration: 1.2).delay(0.3), value: animate)
//
//                Text("Your compassionate care companion")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                    .opacity(animate ? 1 : 0)
//                    .animation(.easeIn(duration: 1.2).delay(0.6), value: animate)
//
//                Spacer()
//
//                if animate {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: Color(.sRGB, red: 0.651, green: 0.294, blue: 0.165)))
//                        .scaleEffect(1.4)
//                        .padding(.bottom, 60)
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            animate = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                onFinish()
//            }
//        }
//    }
//}
