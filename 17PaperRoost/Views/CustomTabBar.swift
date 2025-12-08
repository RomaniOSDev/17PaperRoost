import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                let tab = tabs[index]
                let isSelected = selectedTab == index
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 20))
                            .foregroundColor(isSelected ? Color("AccentColor") : Color("SecondaryTextColor"))
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isSelected)
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(isSelected ? .semibold : .medium)
                            .foregroundColor(isSelected ? Color("AccentColor") : Color("SecondaryTextColor"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("CardColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color("AccentColor"), lineWidth: 2)
                                    )
                                    .scaleEffect(1.05)
                                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("BackgroundColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("CardColor"), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabItem {
    let icon: String
    let selectedIcon: String
    let title: String
}

extension TabItem {
    static let vault = TabItem(icon: "house", selectedIcon: "house.fill", title: "Vault")
    static let add = TabItem(icon: "plus.circle", selectedIcon: "plus.circle.fill", title: "Add")
    static let search = TabItem(icon: "magnifyingglass", selectedIcon: "magnifyingglass", title: "Search")
    static let settings = TabItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings")
}
