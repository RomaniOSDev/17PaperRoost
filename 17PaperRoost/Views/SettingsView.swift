import SwiftUI
import LocalAuthentication
import SafariServices
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var contractManager: ContractManager
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var showingResetAlert = false
    @State private var showingPrivacyPolicy = false
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        dataSection
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all contracts and data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: URL(string: "https://www.termsfeed.com/live/392f606f-d7a5-4b3f-b40a-83964ef5ac47")!)
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView(isOnboardingComplete: $showingOnboarding)
        }

    }
    

    
    
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Data Management")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryTextColor)
            
            VStack(spacing: 16) {
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reset All Data")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Text("Delete all contracts and data")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                    .padding()
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                

                
                Button(action: {
                    showOnboardingAgain()
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Onboarding")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Learn how to use the app")
                                .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                    .padding()
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                

            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryTextColor)
            
            VStack(spacing: 16) {
                Button(action: {
                    requestAppReview()
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rate App")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Support us with a rating")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                    .padding()
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingPrivacyPolicy = true
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .font(.title2)
                            .foregroundColor(.secondaryTextColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy Policy")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primaryTextColor)
                            
                            Text("Read our privacy policy")
                                .font(.caption)
                                .foregroundColor(.secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                    .padding()
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Version")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryTextColor)
                        
                        Text("1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondaryTextColor)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color("CardColor"))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private func resetAllData() {
        print("Data reset requested")
        contractManager.contracts.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedContracts")
        print("All contracts have been deleted")
    }
    
    private func requestAppReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        // Показываем стандартный попап рейтинга от Apple
        SKStoreReviewController.requestReview(in: scene)
    }
    

    
    private func showOnboardingAgain() {
        showingOnboarding = true
    }
    

}



struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}





