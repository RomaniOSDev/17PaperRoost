import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var pinInput = ""
    @State private var showingPINInput = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingCreatePIN = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("ContractVault")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    if authManager.isFirstLaunch {
                        Text("Create Your PIN Code")
                            .font(.title3)
                            .foregroundColor(Color("SecondaryTextColor"))
                    } else {
                        Text("Secure Contract Storage")
                            .font(.title3)
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                }
                
                                VStack(spacing: 20) {
                    if authManager.isFirstLaunch {
                        // Экран создания PIN-кода
                        Button(action: {
                            showingCreatePIN = true
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.title2)
                                Text("Create PIN Code")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("AccentColor"))
                            .cornerRadius(16)
                        }
                    } else {
                        // Обычный экран аутентификации
                        if authManager.biometricType != .none && authManager.useBiometrics {
                            Button(action: {
                                print("🔐 Biometric button tapped")
                                authManager.authenticate()
                            }) {
                                HStack {
                                    Image(systemName: authManager.biometricType == .faceID ? "faceid" : "touchid")
                                        .font(.title2)
                                    Text(authManager.biometricType == .faceID ? "Use Face ID" : "Use Touch ID")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("AccentColor"))
                                .cornerRadius(16)
                            }
                        }
                        
                        Button(action: {
                            print("🔐 PIN button tapped")
                            showingPINInput = true
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.title2)
                                Text("Use PIN")
                                    .font(.title3)
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(Color("AccentColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("CardColor"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("AccentColor"), lineWidth: 2)
                            )
                        }
                    }
                    

                }
                .padding(.horizontal, 40)
            }
        }
        .sheet(isPresented: $showingPINInput) {
            PINInputView(
                pinInput: $pinInput,
                onAuthenticate: { pin in
                    print("🔐 PINInputView onAuthenticate called with PIN: '\(pin)'")
                    
                    // Call authentication
                    let success = authManager.authenticateWithPIN(pin)
                    print("🔐 Authentication call result: \(success)")
                    
                    // Wait a bit for state to update, then check isAuthenticated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("🔐 Checking authentication state after delay: \(authManager.isAuthenticated)")
                        
                        if authManager.isAuthenticated {
                            print("🔐 Authentication successful, dismissing PINInputView")
                            showingPINInput = false
                            pinInput = "" // Clear PIN input
                        } else {
                            print("🔐 Authentication failed, showing alert")
                            alertMessage = "Incorrect PIN. Please try again."
                            showingAlert = true
                        }
                    }
                }
            )
        }
        .alert("Authentication Failed", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingCreatePIN) {
            CreatePINView { newPin in
                authManager.createPINCode(newPin)
                showingCreatePIN = false
                // После создания PIN пользователь автоматически проходит в приложение
            }
        }
        .onAppear {
            print("🔐 AuthenticationView appeared")
        }
    }
}

struct PINInputView: View {
    @Binding var pinInput: String
    let onAuthenticate: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Enter PIN")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text("Enter your 4-digit PIN")
                        .font(.caption)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                
                VStack(spacing: 20) {
                    SecureField("PIN", text: $pinInput)
                        .textFieldStyle(ModernTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: pinInput) { newValue in
                            // Limit to 4 digits
                            if newValue.count > 4 {
                                pinInput = String(newValue.prefix(4))
                            }
                        }
                    
                    Text("PIN entered: \(pinInput)")
                        .font(.caption)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        print("🔐 Authenticate button tapped with PIN: '\(pinInput)'")
                        onAuthenticate(pinInput)
                    }) {
                        Text("Authenticate")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(pinInput.count == 4 ? Color("AccentColor") : Color.gray)
                            .cornerRadius(16)
                    }
                    .disabled(pinInput.count != 4)
                    
                    Button("Cancel") {
                        print("🔐 Cancel button tapped")
                        dismiss()
                    }
                    .foregroundColor(Color("SecondaryTextColor"))
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            print("🔐 PINInputView appeared")
        }
    }
}
