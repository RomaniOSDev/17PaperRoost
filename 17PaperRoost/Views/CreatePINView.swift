import SwiftUI
import UIKit

struct CreatePINView: View {
    let onPINCreated: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var pinInput = ""
    @State private var confirmPinInput = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Create PIN Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text("Enter a 4-digit PIN code")
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PIN Code")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                                                            SecureField("Enter PIN", text: $pinInput)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .keyboardType(.numberPad)
                            .onChange(of: pinInput) { newValue in
                                if newValue.count > 4 {
                                    pinInput = String(newValue.prefix(4))
                                }
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm PIN")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                                                            SecureField("Confirm PIN", text: $confirmPinInput)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .keyboardType(.numberPad)
                            .onChange(of: confirmPinInput) { newValue in
                                if newValue.count > 4 {
                                    confirmPinInput = String(newValue.prefix(4))
                                }
                            }
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        createPIN()
                    }) {
                        Text("Create PIN")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canCreatePIN ? Color("AccentColor") : Color.gray)
                            .cornerRadius(16)
                    }
                    .disabled(!canCreatePIN)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("SecondaryTextColor"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .alert("PIN Creation Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var canCreatePIN: Bool {
        pinInput.count == 4 && confirmPinInput.count == 4 && pinInput == confirmPinInput
    }
    
    private func createPIN() {
        guard pinInput.count == 4 else {
            alertMessage = "PIN must be 4 digits"
            showingAlert = true
            return
        }
        
        guard pinInput == confirmPinInput else {
            alertMessage = "PIN codes don't match"
            showingAlert = true
            return
        }
        
        // Создаем PIN и сразу закрываем экран
        onPINCreated(pinInput)
        dismiss()
    }
    
    private func hideKeyboard() {
        // Надежный способ скрыть клавиатуру
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Дополнительно - скрываем все текстовые поля
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(true)
    }
}
