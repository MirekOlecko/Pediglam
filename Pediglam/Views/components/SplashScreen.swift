import SwiftUI

struct SplashScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9
    var onComplete: () -> Void

    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ZStack {
            PremiumBackground()

            VStack(spacing: 18) {
                Group {
                    if isDark {
                        Image("AlicjaLogo")
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    } else {
                        Image("AlicjaLogo")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 210, height: 210)
                .padding(24)
                .background(Color.elevatedCardBackground)
                .clipShape(.rect(cornerRadius: 38, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.premiumStroke, lineWidth: 1)
                )
                .shadow(color: Color.premiumShadow, radius: 28, x: 0, y: 16)

                Text("Pediglam")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1
                scale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}
