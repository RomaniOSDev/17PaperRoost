import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Welcome to ContractVault",
            subtitle: "Secure, offline contract management",
            description: "Store and manage your contracts locally with military-grade security. No internet required, no data shared.",
            imageName: "lock.shield.fill",
            backgroundColor: Color("BackgroundColor")
        ),
        OnboardingPage(
            title: "Digital Signatures",
            subtitle: "Sign contracts with your finger",
            description: "Create beautiful digital signatures using our intuitive drawing canvas. Your signature stays private and secure.",
            imageName: "signature",
            backgroundColor: Color("CardColor")
        ),
        OnboardingPage(
            title: "Smart Organization",
            subtitle: "Find contracts instantly",
            description: "Search, filter, and organize contracts by type, status, or date. Never lose track of important documents again.",
            imageName: "magnifyingglass",
            backgroundColor: Color("BackgroundColor")
        ),
        OnboardingPage(
            title: "Complete Privacy",
            subtitle: "100% offline & secure",
            description: "All data stays on your device. Use Face ID, Touch ID, or PIN for secure access. Your privacy is our priority.",
            imageName: "hand.raised.fill",
            backgroundColor: Color("CardColor")
        )
    ]
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(Color("SecondaryTextColor"))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Bottom section with indicators and buttons
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color("AccentColor") : Color("SecondaryColor"))
                                .frame(width: 12, height: 12)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(Color("SecondaryTextColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("CardColor"))
                            .cornerRadius(16)
                        }
                        
                        Button(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next") {
                            if currentPage == onboardingPages.count - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("AccentColor"))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isOnboardingComplete = true
        }
        UserDefaults.standard.set(true, forKey: "OnboardingComplete")
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(Color("AccentColor"))
                .padding(.bottom, 20)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryTextColor"))
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("AccentColor"))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .background(page.backgroundColor)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}
