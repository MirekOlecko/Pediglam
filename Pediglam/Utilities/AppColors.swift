import SwiftUI
import UIKit

extension Color {
    // Accents
    static let busyColor = Color(red: 255/255, green: 107/255, blue: 107/255)
    static let freeColor = Color(red: 81/255, green: 207/255, blue: 102/255)
    static let iosBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
    static let premiumGold = Color(red: 203/255, green: 162/255, blue: 89/255)
    static let premiumInk = Color(red: 28/255, green: 34/255, blue: 52/255)
    
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

    static let elevatedCardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 24/255, green: 29/255, blue: 48/255, alpha: 1.0)
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.96)
    })

    static let softFill = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 31/255, green: 37/255, blue: 58/255, alpha: 1.0)
            : UIColor(red: 247/255, green: 248/255, blue: 251/255, alpha: 1.0)
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

    static let premiumStroke = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.055)
    })

    static let premiumShadow = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.26)
            : UIColor(red: 33/255, green: 45/255, blue: 70/255, alpha: 0.10)
    })
}

enum AppStyle {
    static let cardRadius: CGFloat = 22
    static let compactRadius: CGFloat = 16
    static let controlRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 18

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [.iosBlue, Color(red: 63/255, green: 141/255, blue: 255/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var freeGradient: LinearGradient {
        LinearGradient(
            colors: [.freeColor, Color(red: 33/255, green: 181/255, blue: 126/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var busyGradient: LinearGradient {
        LinearGradient(
            colors: [.busyColor, Color(red: 238/255, green: 92/255, blue: 112/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct PremiumBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color.systemBackground

            LinearGradient(
                colors: colorScheme == .dark
                    ? [
                        Color.iosBlue.opacity(0.18),
                        Color.premiumInk.opacity(0.16),
                        Color.systemBackground
                    ]
                    : [
                        Color.iosBlue.opacity(0.12),
                        Color.premiumGold.opacity(0.08),
                        Color.systemBackground
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

struct PremiumIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.iosBlue)
                .frame(width: 40, height: 40)
                .background(Color.elevatedCardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.premiumStroke, lineWidth: 1)
                )
                .shadow(color: Color.premiumShadow, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(systemName))
    }
}

struct PremiumSectionTitle: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondaryText)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondaryText)
            }
        }
    }
}

private struct PremiumCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(Color.elevatedCardBackground)
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.premiumStroke, lineWidth: 1)
            )
            .shadow(color: Color.premiumShadow, radius: shadowRadius, x: 0, y: shadowRadius / 2)
    }
}

extension View {
    func premiumCard(cornerRadius: CGFloat = AppStyle.cardRadius, shadowRadius: CGFloat = 16) -> some View {
        modifier(PremiumCardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }

    func premiumFormSurface() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.systemBackground)
            .tint(.iosBlue)
    }
}
