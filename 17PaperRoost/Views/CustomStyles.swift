import SwiftUI

// MARK: - Modern TextField Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
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

// MARK: - Modern Button Style
struct ModernButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    init(isPrimary: Bool = true) {
        self.isPrimary = isPrimary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(isPrimary ? .white : Color("PrimaryTextColor"))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isPrimary {
                        LinearGradient(
                            colors: [Color("GradientStart"), Color("GradientEnd")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color("CardColor")
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isPrimary ? Color.clear : Color("GradientStart"),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: isPrimary ? Color("GradientStart").opacity(0.3) : Color.black.opacity(0.1),
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Modern Card Style
struct ModernCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("CardColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("GradientStart").opacity(0.3), Color("GradientEnd").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Modern Icon Style
struct ModernIconStyle: ViewModifier {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color("GradientStart")) {
        self.size = size
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundColor(color)
            .frame(width: size + 16, height: size + 16)
            .background(
                Circle()
                    .fill(color.opacity(0.1))
            )
    }
}

// MARK: - Color Extensions
extension Color {
    static let backgroundColor = Color("BackgroundColor")
    static let cardColor = Color("CardColor")
    static let accentColor = Color("AccentColor")
    static let secondaryColor = Color("SecondaryColor")
    static let primaryTextColor = Color("PrimaryTextColor")
    static let secondaryTextColor = Color("SecondaryTextColor")
    static let successColor = Color("SuccessColor")
}

// MARK: - View Extensions
extension View {
    func modernCard() -> some View {
        self.modifier(ModernCardStyle())
    }
    
    func modernIcon(size: CGFloat = 24, color: Color = Color("GradientStart")) -> some View {
        self.modifier(ModernIconStyle(size: size, color: color))
    }
}
