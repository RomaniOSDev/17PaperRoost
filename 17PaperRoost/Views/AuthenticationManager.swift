import SwiftUI
import LocalAuthentication
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: LABiometryType = .none
    @Published var useBiometrics = true
    @Published var usePIN = false
    @Published var pinCode = ""
    @Published var isFirstLaunch = true
    
    private let context = LAContext()
    private let userDefaults = UserDefaults.standard
    
    init() {
        checkBiometricType()
        checkFirstLaunch()
        loadPINCode()
        print("🔐 AuthenticationManager initialized")
    }
    
    func checkBiometricType() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
            print("🔐 Biometric type detected: \(biometricType)")
        } else {
            print("🔐 No biometrics available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func authenticate() {
        print("🔐 authenticate() called")
        if useBiometrics && biometricType != .none {
            print("🔐 Using biometric authentication")
            authenticateWithBiometrics()
        } else if usePIN {
            print("🔐 Using PIN authentication")
            // PIN authentication will be handled by the UI
        } else {
            print("🔐 No authentication method selected, allowing access")
            isAuthenticated = true
        }
    }
    
    func authenticateWithPIN(_ pin: String) -> Bool {
        print("🔐 authenticateWithPIN called with: '\(pin)'")
        print("🔐 Stored PIN: '\(pinCode)'")
        print("🔐 PIN match: \(pin == pinCode)")
        
        let success = pin == pinCode
        
        if success {
            print("🔐 PIN authentication successful!")
            // Update state immediately on main thread
            DispatchQueue.main.async {
                self.isAuthenticated = true
                print("🔐 isAuthenticated set to: \(self.isAuthenticated)")
            }
        } else {
            print("🔐 PIN authentication failed!")
        }
        
        return success
    }
    
    private func authenticateWithBiometrics() {
        let reason = "Authenticate to access ContractVault"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("🔐 Biometric authentication successful!")
                    self.isAuthenticated = true
                } else {
                    print("🔐 Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func logout() {
        print("🔐 Logging out")
        isAuthenticated = false
        savePINCode() // Сохраняем состояние
    }
    
    func resetAuthentication() {
        print("🔐 Resetting authentication state")
        isAuthenticated = false
    }
    
    func resetPINCode() {
        print("🔐 Resetting PIN code")
        pinCode = ""
        isFirstLaunch = true
        savePINCode()
        print("🔐 PIN code reset")
    }
    
    func createPINCode(_ newPin: String) {
        print("🔐 Creating new PIN code")
        pinCode = newPin
        isFirstLaunch = false
        usePIN = true
        isAuthenticated = true // После создания PIN автоматически аутентифицируемся
        savePINCode()
        print("🔐 PIN code created: \(pinCode)")
    }
    
    private func loadPINCode() {
        if let savedPin = userDefaults.string(forKey: "UserPINCode"), !savedPin.isEmpty {
            pinCode = savedPin
            isFirstLaunch = false
            usePIN = true
            print("🔐 PIN code loaded from storage: \(pinCode)")
        } else {
            pinCode = ""
            isFirstLaunch = true
            usePIN = false
            print("🔐 No PIN code found, first launch")
        }
    }
    
    private func savePINCode() {
        userDefaults.set(pinCode, forKey: "UserPINCode")
        userDefaults.set(isFirstLaunch, forKey: "IsFirstLaunch")
        userDefaults.set(usePIN, forKey: "UsePIN")
        print("🔐 PIN code saved to storage")
    }
    
    private func checkFirstLaunch() {
        // Проверяем только если значения не были установлены в loadPINCode
        if userDefaults.object(forKey: "IsFirstLaunch") == nil {
            isFirstLaunch = true
            usePIN = false
            print("🔐 First launch detected, setting defaults")
        }
        print("🔐 Current state - First launch: \(isFirstLaunch), Use PIN: \(usePIN)")
    }
}
