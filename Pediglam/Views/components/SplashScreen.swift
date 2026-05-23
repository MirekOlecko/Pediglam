import SwiftUI

struct SplashScreen: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("AlicjaLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
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
