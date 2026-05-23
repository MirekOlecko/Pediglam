import SwiftUI

@main
struct PediglamApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen {
                    showSplash = false
                }
            } else {
                MainTabView()
                    .environmentObject(themeManager)
            }
        }
    }
}
