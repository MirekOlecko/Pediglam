import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("appTheme") var theme: String = AppTheme.system.rawValue {
        didSet { objectWillChange.send() }
    }
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: theme) ?? .system
    }
}
