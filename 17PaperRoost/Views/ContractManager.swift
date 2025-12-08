import SwiftUI
import Foundation
import Combine

class ContractManager: ObservableObject {
    @Published var contracts: [Contract] = []
    
    init() {
        print("🔧 ContractManager initializing...")
        loadContracts()
        
        // Если нет сохраненных контрактов, создаем тестовые
        if contracts.isEmpty {
            print("🔧 No contracts found, creating sample contracts...")
            createSampleContracts()
        }
        
        print("🔧 ContractManager initialized with \(contracts.count) contracts")
        print("🔧 First contract: \(contracts.first?.title ?? "None")")
    }
    
    func addContract(_ contract: Contract) {
        contracts.append(contract)
        print("✅ Contract added: \(contract.title)")
        print("🔍 Contract signature data: \(contract.signatureData?.count ?? 0) bytes")
        saveContracts()
    }
    
    func deleteContract(_ contract: Contract) {
        if let index = contracts.firstIndex(where: { $0.id == contract.id }) {
            let deletedContract = contracts.remove(at: index)
            print("✅ Contract deleted: \(deletedContract.title)")
            saveContracts()
        } else {
            print("❌ Contract not found for deletion")
        }
    }
    
    func updateContract(_ contract: Contract) {
        if let index = contracts.firstIndex(where: { $0.id == contract.id }) {
            contracts[index] = contract
            print("✅ Contract updated: \(contract.title)")
            saveContracts()
        } else {
            print("❌ Contract not found for update")
        }
    }
    
    private func saveContracts() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(contracts) {
            UserDefaults.standard.set(encoded, forKey: "SavedContracts")
            print("✅ Contracts saved: \(contracts.count)")
        } else {
            print("❌ Failed to save contracts")
        }
    }
    
    func createSampleContracts() {
        print("🎯 Creating 50 sample contracts...")
        
        let contractTypes = ["Employment", "Rental", "Service", "Purchase", "Partnership", "Consulting", "License", "Franchise", "Distribution", "Maintenance", "Insurance", "Loan", "Lease", "Subscription", "Support"]
        let statuses: [ContractStatus] = [.active, .pending, .completed, .cancelled]
        let companies = ["Apple Inc.", "Microsoft Corp.", "Google LLC", "Amazon.com", "Tesla Inc.", "Netflix Inc.", "Meta Platforms", "NVIDIA Corp.", "Adobe Inc.", "Salesforce Inc.", "IBM Corp.", "Oracle Corp.", "Intel Corp.", "Cisco Systems", "Zoom Video"]
        let names = ["John Smith", "Emma Johnson", "Michael Brown", "Sarah Davis", "David Wilson", "Lisa Anderson", "Robert Taylor", "Jennifer Martinez", "William Garcia", "Amanda Rodriguez", "Christopher Lee", "Jessica White", "Daniel Clark", "Ashley Lewis", "Matthew Hall"]
        
        for i in 1...50 {
            let contractType = contractTypes.randomElement() ?? "Service"
            let status = statuses.randomElement() ?? .active
            let company = companies.randomElement() ?? "Company Inc."
            let participant = names.randomElement() ?? "John Doe"
            
            let startDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...365), to: Date()) ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 30...730), to: startDate) ?? Date()
            
                        let contract = Contract(
                title: "Contract #\(String(format: "%03d", i)) - \(contractType)",
                contractType: contractType,
                startDate: startDate,
                endDate: endDate,
                participants: "\(participant) & \(company)",
                notes: "Sample contract for testing purposes. This is contract number \(i) with \(contractType) type.",
                status: status,
                signatureData: nil,
                attachmentData: nil,
                attachmentName: nil
            )
            
            contracts.append(contract)
        }
        
        print("✅ Created \(contracts.count) sample contracts")
        saveContracts()
    }
    
    private func loadContracts() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: "SavedContracts"),
           let decoded = try? decoder.decode([Contract].self, from: data) {
            contracts = decoded
            print("✅ Contracts loaded: \(contracts.count)")
        } else {
            print("ℹ️ No saved contracts found")
        }
    }
}

struct Contract: Identifiable, Codable {
    let id: UUID
    var title: String
    var contractType: String
    var startDate: Date
    var endDate: Date
    var participants: String
    var notes: String
    var status: ContractStatus
    var signatureData: Data?
    var attachmentData: Data?
    var attachmentName: String?
    var createdAt: Date
    
    init(title: String, contractType: String, startDate: Date, endDate: Date, participants: String, notes: String, status: ContractStatus = .active, signatureData: Data? = nil, attachmentData: Data? = nil, attachmentName: String? = nil) {
        self.id = UUID()
        self.title = title
        self.contractType = contractType
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
        self.notes = notes
        self.status = status
        self.signatureData = signatureData
        self.attachmentData = attachmentData
        self.attachmentName = attachmentName
        self.createdAt = Date()
    }
}

enum ContractStatus: String, CaseIterable, Codable {
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .active:
            return Color.green
        case .pending:
            return Color.orange
        case .completed:
            return Color.blue
        case .cancelled:
            return Color.red
        }
    }
}
