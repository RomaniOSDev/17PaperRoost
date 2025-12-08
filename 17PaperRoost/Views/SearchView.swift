import SwiftUI
import UIKit

struct SearchView: View {
    @EnvironmentObject var contractManager: ContractManager
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var searchText = ""
    @State private var selectedStatusFilter = "All"
    @State private var selectedTypeFilter = "All"
    @State private var showingTagsView = false
    
    private let statusOptions = ["All", "Active", "Pending", "Completed", "Cancelled"]
    private let typeOptions = ["All", "Employment", "Rental", "Service", "Purchase", "Partnership", "Other"]
    
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
                
                VStack(spacing: 24) {
                    searchHeader
                    searchBar
                    filterSection
                    
                    if filteredContracts.isEmpty {
                        emptyStateView
                    } else {
                        searchResultsView
                    }
                }
                .padding(20)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationTitle("Search & Filter")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTagsView = true
                    }) {
                        Image(systemName: "tag.fill")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
            .sheet(isPresented: $showingTagsView) {
                TagsView(contracts: contractManager.contracts)
            }
        }
    }
    
    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find Contracts")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            Text("Search by title, participants, or notes")
                .font(.subheadline)
                .foregroundColor(Color("SecondaryTextColor"))
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("SecondaryTextColor"))
            
            TextField("Search contracts...", text: $searchText)
                .textFieldStyle(ModernTextFieldStyle())
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status Filter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Picker("Status", selection: $selectedStatusFilter) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color("BackgroundColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("SecondaryColor"), lineWidth: 1)
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type Filter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Picker("Type", selection: $selectedTypeFilter) {
                        ForEach(typeOptions, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color("BackgroundColor"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("SecondaryColor"), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(Color("SecondaryTextColor"))
            
            VStack(spacing: 12) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text("Try adjusting your search terms or filters")
                    .font(.body)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredContracts, id: \.id) { contract in
                    SearchResultCard(contract: contract, searchText: searchText)
                }
            }
        }
    }
    
    private var filteredContracts: [Contract] {
        var filtered = contractManager.contracts
        
        if !searchText.isEmpty {
            filtered = filtered.filter { contract in
                contract.title.localizedCaseInsensitiveContains(searchText) ||
                contract.participants.localizedCaseInsensitiveContains(searchText) ||
                contract.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedStatusFilter != "All" {
            filtered = filtered.filter { $0.status.rawValue == selectedStatusFilter }
        }
        
        if selectedTypeFilter != "All" {
            filtered = filtered.filter { $0.contractType == selectedTypeFilter }
        }
        
        return filtered
    }
}

struct SearchResultCard: View {
    let contract: Contract
    let searchText: String
    
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
                        .lineLimit(1)
                }
            }
            
            if !contract.notes.isEmpty {
                Text(contract.notes)
                    .font(.caption)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .lineLimit(2)
                    .padding(.top, 8)
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
    
    private var highlightedTitle: AttributedString {
        var attributedString = AttributedString(contract.title)
        
        if !searchText.isEmpty {
            let range = attributedString.range(of: searchText, options: .caseInsensitive)
            if let range = range {
                attributedString[range].foregroundColor = Color("AccentColor")
                attributedString[range].font = .boldSystemFont(ofSize: 16)
            }
        }
        
        return attributedString
    }
    

}

struct TagsView: View {
    let contracts: [Contract]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        statusTagsSection
                        typeTagsSection
                        dateTagsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Browse by Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
    }
    
    private var statusTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(["Active", "Pending", "Completed", "Cancelled"], id: \.self) { status in
                    let count = contracts.filter { $0.status.rawValue == status }.count
                    TagView(title: status, count: count, color: statusColor(for: status))
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var typeTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contract Type")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(["Employment", "Rental", "Service", "Purchase", "Partnership", "Other"], id: \.self) { type in
                    let count = contracts.filter { $0.contractType == type }.count
                    TagView(title: type, count: count, color: typeColor(for: type))
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private var dateTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                let recentContracts = contracts.sorted { $0.createdAt > $1.createdAt }.prefix(6)
                ForEach(Array(recentContracts.enumerated()), id: \.element.id) { index, contract in
                    TagView(title: "Contract \(index + 1)", count: 1, color: Color("AccentColor"))
                }
            }
        }
        .padding(20)
        .background(Color("CardColor"))
        .cornerRadius(16)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Active": return .green
        case "Pending": return .orange
        case "Completed": return .blue
        case "Cancelled": return .red
        default: return Color("SecondaryTextColor")
        }
    }
    
    private func typeColor(for type: String) -> Color {
        switch type {
        case "Employment": return .blue
        case "Rental": return .purple
        case "Service": return .orange
        case "Purchase": return .green
        case "Partnership": return .pink
        default: return Color("SecondaryTextColor")
        }
    }
    
}

struct TagView: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color("PrimaryTextColor"))
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
