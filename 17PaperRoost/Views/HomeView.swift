import SwiftUI


struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var contractManager: ContractManager
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var selectedSortOption = "Date"
    @State private var showingAddContract = false
    
    private let sortOptions = ["Date", "Status", "Type"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    headerSection
                    
                    if contractManager.contracts.isEmpty {
                        emptyStateView
                    } else {
                        contractListView
                    }
                }
            }
            .navigationTitle("Contract Vault")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        authManager.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContract = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
            .sheet(isPresented: $showingAddContract) {
                AddContractView()
                    .environmentObject(contractManager)
                    .environmentObject(signatureManager)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sort by")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Picker("Sort", selection: $selectedSortOption) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
            }
            

        }
        .padding(20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("SecondaryTextColor"))
            
            VStack(spacing: 12) {
                Text("No Contracts Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text("Start by adding your first contract")
                    .font(.body)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddContract = true
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.title2)
                    Text("Add Contract")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("AccentColor"))
                .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var contractListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sortedContracts, id: \.id) { contract in
                    NavigationLink(destination: ContractDetailView(contract: contract)
                        .environmentObject(contractManager)) {
                        ContractCardView(contract: contract)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var sortedContracts: [Contract] {
        switch selectedSortOption {
        case "Date":
            return contractManager.contracts.sorted { $0.createdAt > $1.createdAt }
        case "Status":
            return contractManager.contracts.sorted { $0.status.rawValue < $1.status.rawValue }
        case "Type":
            return contractManager.contracts.sorted { $0.contractType < $1.contractType }
        default:
            return contractManager.contracts
        }
    }
}



struct ContractCardView: View {
    let contract: Contract
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(contract.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .lineLimit(2)
                    
                    Text(contract.contractType)
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color("AccentColor").opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(contract.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(contract.status.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(contract.status.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text(contract.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
            }
            
            if !contract.participants.isEmpty {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(Color("SecondaryTextColor"))
                    
                    Text(contract.participants)
                        .font(.caption)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(contract.status.color.opacity(0.3), lineWidth: 1)
        )
    }
    

}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
