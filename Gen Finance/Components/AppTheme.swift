import SwiftUI

// MARK: - App Theme Protocol
protocol AppTheme {
    var primary: Color { get }
    var primary900: Color { get }
    var primary800: Color { get }
    var primary700: Color { get }
    var primary600: Color { get }
    var primary500: Color { get }
    var primary250: Color { get }
    var primary200: Color { get }
    var primary150: Color { get }
    var primary100: Color { get }
    var primary080: Color { get }
    var primary050: Color { get }
    
    var contentPrimary: Color { get }
    var contentSecondary: Color { get }
    
    var systemBackground: Color { get }
    var secondarySystemBackground: Color { get }
    var tertiarySystemBackground: Color { get }
    
    var negative: Color { get }
    var positive: Color { get }
    var alwaysLight: Color { get }
    
    var gray: Color { get }
    
    var shadow: Color { get }
}

// MARK: - Indigo Theme Implementation
struct PrimaryTheme: AppTheme {
    let primary = Color.indigo
    let primary900 = Color.indigo.opacity(0.9)
    let primary800 = Color.indigo.opacity(0.8)
    let primary700 = Color.indigo.opacity(0.7)
    let primary600 = Color.indigo.opacity(0.6)
    let primary500 = Color.indigo.opacity(0.5)
    let primary250 = Color.indigo.opacity(0.25)
    let primary200 = Color.indigo.opacity(0.2)
    let primary150 = Color.indigo.opacity(0.15)
    let primary100 = Color.indigo.opacity(0.1)
    let primary080 = Color.indigo.opacity(0.08)
    let primary050 = Color.indigo.opacity(0.05)
    
    let contentPrimary = Color.primary
    let contentSecondary = Color.primary.opacity(0.8)
    
    let negative = Color.red
    let positive = Color.green
    let alwaysLight = Color.white
    
    let systemBackground = Color(.systemBackground)
    let secondarySystemBackground = Color(.secondarySystemBackground)
    let tertiarySystemBackground = Color(.tertiarySystemBackground)
    
    let gray = Color.gray
    let shadow = Color.black.opacity(0.07)
}

// MARK: - Theme Environment Key
struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = PrimaryTheme()
}

// MARK: - Environment Extension
extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Injection
extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
