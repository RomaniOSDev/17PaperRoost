//
//  ContentView.swift
//  PaperRoost
//
//  Created by Denis on 29.08.2025.
//

import SwiftUI
import Foundation
import Combine

struct MainTabView: View {
    @StateObject private var contractManager = ContractManager()
    @EnvironmentObject var signatureManager: SignatureManager
    @State private var selectedTab = 0
    
    init() {
        print("🔧 MainTabView initializing...")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(contractManager)
                .environmentObject(signatureManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Vault")
                }
                .tag(0)
            
            AddContractView()
                .environmentObject(contractManager)
                .environmentObject(signatureManager)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
                .tag(1)
            
            SearchView()
                .environmentObject(contractManager)
                .environmentObject(signatureManager)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(2)
            
            SettingsView()
                .environmentObject(contractManager)
                .environmentObject(signatureManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.accentColor)
        .preferredColorScheme(.dark)
    }
}
