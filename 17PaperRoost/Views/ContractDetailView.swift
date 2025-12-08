
import SwiftUI
import UIKit

struct ContractDetailView: View {
    let contract: Contract
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var contractManager: ContractManager
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var showingSignatureView = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusEditor = false
    @State private var editingStatus: ContractStatus
    
    init(contract: Contract) {
        self.contract = contract
        self._editingStatus = State(initialValue: contract.status)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    detailsSection
                    signatureSection
                }
                .padding(20)
            }
        }
        .navigationTitle("Contract Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingSignatureView = true
                    }) {
                        Label("View Signature", systemImage: "signature")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("AccentColor"))
                }
            }
        })
        .alert("Delete Contract", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteContract()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this contract? This action cannot be undone.")
        }
        .sheet(isPresented: $showingSignatureView) {
            SignatureDetailView(signatureData: contract.signatureData)
                .environmentObject(signatureManager)
        }
        .onChange(of: showingSignatureView) { newValue in
            if newValue {
                print("🔍 Opening signature view:")
                print("   - Contract ID: \(contract.id)")
                print("   - Signature data size: \(contract.signatureData?.count ?? 0) bytes")
                if let signatureData = contract.signatureData {
                    print("   - Signature data exists: ✅")
                } else {
                    print("   - Signature data exists: ❌")
                }
            }
        }
        .sheet(isPresented: $showingStatusEditor) {
            StatusEditorView(
                currentStatus: $editingStatus,
                onSave: updateContractStatus
            )
        }

    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(contract.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text(contract.contractType)
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color("AccentColor").opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Button(action: {
                        editingStatus = contract.status
                        showingStatusEditor = true
                    }) {
                        HStack {
                            Text(contract.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(contract.status.color)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(contract.status.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(contract.status.color.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Tap to change")
                        .font(.caption2)
                        .foregroundColor(Color("SecondaryTextColor"))
                    
                    Text(contract.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Contract Details")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            VStack(spacing: 16) {
                DetailRow(title: "Start Date", value: contract.startDate.formatted(date: .abbreviated, time: .omitted))
                DetailRow(title: "End Date", value: contract.endDate.formatted(date: .abbreviated, time: .omitted))
                DetailRow(title: "Participants", value: contract.participants.isEmpty ? "Not specified" : contract.participants)
                
                if !contract.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                        Text(contract.notes)
                            .font(.body)
                            .foregroundColor(Color("SecondaryTextColor"))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("BackgroundColor"))
                            .cornerRadius(12)
                    }
                }
            }
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
            
            if let signatureData = contract.signatureData {
                VStack(spacing: 16) {
                    // Кнопка для просмотра подписи
                    Button(action: {
                        showingSignatureView = true
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "signature")
                                .font(.title)
                                .foregroundColor(Color("AccentColor"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("View Signature")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                
                                Text("Tap to view signature in same size as creation window")
                                    .font(.caption)
                                    .foregroundColor(Color("SecondaryTextColor"))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("AccentColor"), lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Информация о подписи
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Signature available")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        if let uiImage = UIImage(data: signatureData) {
                            Text("\(Int(uiImage.size.width))×\(Int(uiImage.size.height)) pixels")
                                .font(.caption)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("CardColor"))
                    .cornerRadius(8)
                }
            } else {
                Text("No signature available")
                    .font(.body)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color("BackgroundColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("SecondaryColor"), lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    

    

    
    private func deleteContract() {
        contractManager.deleteContract(contract)
        dismiss()
    }
    
    private func updateContractStatus() {
        var updatedContract = contract
        updatedContract.status = editingStatus
        contractManager.updateContract(updatedContract)
        showingStatusEditor = false
    }
    

}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color("PrimaryTextColor"))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(Color("SecondaryTextColor"))
            
            Spacer()
        }
    }
}

struct SignatureDetailView: View {
    let signatureData: Data?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signatureManager: SignatureManager
    
    init(signatureData: Data?) {
        self.signatureData = signatureData
        print("🔍 SignatureDetailView init:")
        print("   - Signature data: \(signatureData?.count ?? 0) bytes")
        if let signatureData = signatureData {
            print("   - Data exists: ✅")
        } else {
            print("   - Data exists: ❌")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                if let signatureData = signatureData,
                   let uiImage = UIImage(data: signatureData) {
                    VStack(spacing: 20) {
                        // Заголовок
                        Text("Signature Preview")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("PrimaryTextColor"))
                            .padding(.top, 20)
                        
                        // Белое окно подписи - занимает большую часть экрана
                        ZStack {
                            Rectangle()
                                .fill(.white)
                                .cornerRadius(12)
                            
                            if let signatureImage = signatureManager.getSignatureImage(for: signatureData, targetSize: CGSize(width: 800, height: 500)) {
                                Image(uiImage: signatureImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(40)
                            } else {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(40)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("AccentColor"), lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        Spacer()
                        
                        // Кнопки управления
                        HStack(spacing: 20) {
                            Button("Close") {
                                dismiss()
                            }
                            .foregroundColor(.red)
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("CardColor"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.red, lineWidth: 2)
                            )
                            
                            Button("Done") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("AccentColor"))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(Color("SecondaryColor"))
                        
                        Text("Signature Not Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                        Text("The signature data could not be loaded or is corrupted.")
                            .font(.body)
                            .foregroundColor(Color("SecondaryTextColor"))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        // Кнопки для ошибки
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("AccentColor"))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            })
        }
    }
}

struct StatusEditorView: View {
    @Binding var currentStatus: ContractStatus
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("AccentColor"))
                        
                        Text("Change Contract Status")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(ContractStatus.allCases, id: \.self) { status in
                            Button(action: {
                                currentStatus = status
                            }) {
                                HStack {
                                    Text(status.rawValue)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(currentStatus == status ? .white : Color("PrimaryTextColor"))
                                    
                                    Spacer()
                                    
                                    if currentStatus == status {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(currentStatus == status ? status.color : Color("CardColor"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(currentStatus == status ? status.color : Color("SecondaryColor"), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Color("SecondaryTextColor"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("CardColor"))
                        .cornerRadius(16)
                        
                        Button("Save") {
                            onSave()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("AccentColor"))
                        .cornerRadius(16)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
            }
            .navigationTitle("Change Status")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
