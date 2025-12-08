import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

struct AddContractView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var contractManager: ContractManager
    @EnvironmentObject var signatureManager: SignatureManager
    
    @State private var title = ""
    @State private var contractType = "Employment"
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
    @State private var participants = ""
    @State private var notes = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingSignatureView = false
    @State private var signatureData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    private let contractTypes = ["Employment", "Rental", "Service", "Purchase", "Partnership", "Other"]
    
    func hideKeyboard() {
        // Надежный способ скрыть клавиатуру
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Дополнительно - скрываем все текстовые поля
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(true)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ScrollView {
                    VStack(spacing: 24) {
                        formSection
                        attachmentSection
                        signatureSection
                        buttonsSection
                    }
                    .padding(20)
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationTitle("Add Contract")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        resetForm()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
        .sheet(isPresented: $showingSignatureView) {
            SignatureView(signatureData: $signatureData)
                .environmentObject(signatureManager)
        }
        .alert("Contract", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Contract Details")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            VStack(spacing: 16) {
                CustomTextField(title: "Title", text: $title, placeholder: "Enter contract title")
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Contract Type")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .fontWeight(.semibold)
                    
                    Picker("Contract Type", selection: $contractType) {
                        ForEach(contractTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color("GradientStart"), Color("GradientEnd")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .foregroundColor(Color("PrimaryTextColor"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start Date")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryTextColor"))
                            .fontWeight(.semibold)
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("CardColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color("GradientStart"), Color("GradientEnd")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .foregroundColor(Color("PrimaryTextColor"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("End Date")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryTextColor"))
                            .fontWeight(.semibold)
                        
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("CardColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color("GradientStart"), Color("GradientEnd")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .foregroundColor(Color("PrimaryTextColor"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
                
                CustomTextField(title: "Participants", text: $participants, placeholder: "Enter participant names")
                
                CustomTextField(title: "Notes", text: $notes, placeholder: "Additional notes", isMultiline: true)
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var attachmentSection: some View {
        Group {
            if #available(iOS 17.0, *) {
                attachmentSectioniOS17
            } else {
                attachmentSectioniOS16
            }
        }
    }
    
    @available(iOS 17.0, *)
    private var attachmentSectioniOS17: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attachment")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            if let selectedImageData = selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                VStack(spacing: 12) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                    
                    Button("Remove Attachment") {
                        self.selectedImageData = nil
                        self.selectedItem = nil
                    }
                    .foregroundColor(.red)
                    .font(.subheadline)
                }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos])) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .font(.title2)
                        Text("Select PDF or Image")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Color("AccentColor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentColor"), lineWidth: 2)
                    )
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    private var attachmentSectioniOS16: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attachment")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            Text("Attachment feature requires iOS 17+")
                .font(.caption)
                .foregroundColor(Color("SecondaryTextColor"))
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var signatureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Signature")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            if let signatureData = signatureData {
                VStack(spacing: 12) {
                    Image(uiImage: UIImage(data: signatureData) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 120)
                        .cornerRadius(12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("AccentColor"), lineWidth: 1)
                        )
                    
                    Button("Redraw Signature") {
                        showingSignatureView = true
                    }
                    .foregroundColor(Color("AccentColor"))
                    .font(.subheadline)
                }
            } else {
                Button(action: {
                    showingSignatureView = true
                }) {
                    HStack {
                        Image(systemName: "signature")
                            .font(.title2)
                        Text("Add Signature")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Color("AccentColor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("CardColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentColor"), lineWidth: 2)
                    )
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 16) {
            Button(action: saveContract) {
                HStack(spacing: 12) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                    }
                    Text(isSaving ? "Saving..." : "Save Contract")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if title.isEmpty || signatureData == nil || isSaving {
                            Color.gray
                        } else {
                            LinearGradient(
                                colors: [Color("GradientStart"), Color("GradientEnd")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(
                    color: title.isEmpty || signatureData == nil || isSaving ? 
                    Color.gray.opacity(0.3) : 
                    Color("GradientStart").opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(title.isEmpty || signatureData == nil || isSaving)
            
            Button(action: resetForm) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.title2)
                    Text("Clear Form")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color("PrimaryTextColor"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("CardColor"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("GradientStart"), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    private func saveContract() {
        guard !title.isEmpty else {
            alertMessage = "Please enter a contract title"
            showingAlert = true
            return
        }
        
        guard let signatureData = signatureData else {
            alertMessage = "Please add a signature"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        print("🔍 Creating contract with signature: \(signatureData.count) bytes")
        
        let contract = Contract(
            title: title,
            contractType: contractType,
            startDate: startDate,
            endDate: endDate,
            participants: participants,
            notes: notes,
            signatureData: signatureData,
            attachmentData: selectedImageData,
            attachmentName: selectedItem?.itemIdentifier
        )
        
        print("🔍 Contract created, signature data: \(contract.signatureData?.count ?? 0) bytes")
        contractManager.addContract(contract)
        
        // Сбрасываем все поля
        resetForm()
        
        // Показываем сообщение об успехе
        alertMessage = "Contract saved successfully!"
        showingAlert = true
        isSaving = false
        
        // Закрываем View через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    private func resetForm() {
        title = ""
        contractType = "Service"
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        participants = ""
        notes = ""
        signatureData = nil
        selectedImageData = nil
        selectedItem = nil
        print("🔄 Form reset - all fields cleared")
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isMultiline: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))
                .fontWeight(.semibold)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        isFocused ? 
                                        Color("GradientStart") : 
                                        Color("SecondaryColor").opacity(0.5),
                                        lineWidth: isFocused ? 2 : 1
                                    )
                            )
                    )
                    .foregroundColor(Color("PrimaryTextColor"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .scaleEffect(isFocused ? 1.02 : 1.0)
                    .shadow(
                        color: isFocused ? Color("GradientStart").opacity(0.2) : Color.black.opacity(0.1),
                        radius: isFocused ? 12 : 8,
                        x: 0,
                        y: isFocused ? 6 : 4
                    )
                    .animation(.easeInOut(duration: 0.3), value: isFocused)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(ModernTextFieldStyle())
                    .focused($isFocused)
            }
        }
    }
}
