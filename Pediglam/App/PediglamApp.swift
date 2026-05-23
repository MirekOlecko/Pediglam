import SwiftUI

@main
struct PediglamApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen {
                    showSplash = false
                }
            } else {
                MainTabView()
            }
        }
    }
}
