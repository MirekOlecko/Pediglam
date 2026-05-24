import SwiftUI
import UIKit

extension Color {
    // Accents
    static let busyColor = Color(red: 255/255, green: 107/255, blue: 107/255)
    static let freeColor = Color(red: 81/255, green: 207/255, blue: 102/255)
    static let iosBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
    
    // Background — warm off-white (light) / dark navy blue (dark)
    static let systemBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 11/255, green: 14/255, blue: 26/255, alpha: 1.0)
            : UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    })
    
    // Cards — crisp white (light) / elevated navy (dark)
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 18/255, green: 22/255, blue: 38/255, alpha: 1.0)
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    })
    
    static let primaryText = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : UIColor(red: 29/255, green: 29/255, blue: 31/255, alpha: 1.0)
    })
    
    static let secondaryText = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0) : UIColor(red: 134/255, green: 134/255, blue: 139/255, alpha: 1.0)
    })
    
    static let separator = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 38/255, green: 38/255, blue: 40/255, alpha: 1.0) : UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0)
    })
}
