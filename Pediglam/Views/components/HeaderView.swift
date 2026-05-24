import SwiftUI

struct HeaderView: View {
    var body: some View {
        Color.clear
            .frame(height: 8)
    }
}

struct PremiumScreenHeader<Accessory: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accessory: Accessory

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accessory = accessory()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppStyle.accentGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.iosBlue.opacity(0.22), radius: 12, x: 0, y: 7)

                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            accessory
        }
        .padding(.horizontal, AppStyle.horizontalPadding)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}

extension PremiumScreenHeader where Accessory == EmptyView {
    init(title: String, subtitle: String, systemImage: String) {
        self.init(title: title, subtitle: subtitle, systemImage: systemImage) {
            EmptyView()
        }
    }
}
