//
//  ContentView.swift
//  17PaperRoost
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var signatureManager = SignatureManager.shared
    @AppStorage("OnboardingComplete") private var isOnboardingComplete = false
    var body: some View {
        if !isOnboardingComplete {
            OnboardingView(isOnboardingComplete: $isOnboardingComplete)
        } else if authManager.isAuthenticated {
            MainTabView()
                .environmentObject(authManager)
                .environmentObject(signatureManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // При сворачивании приложения сбрасываем аутентификацию
                    authManager.logout()
                }
        } else {
            AuthenticationView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
}
