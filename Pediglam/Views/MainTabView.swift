import SwiftUI
import EventKit

struct MainTabView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: viewModel)
                    .tabItem {
                        Label("Dashboard", systemImage: "rectangle.split.2x2.fill")
                    }
                    .tag(0)
                
                ContentView(viewModel: viewModel)
                    .tabItem {
                        Label("Day", systemImage: "clock")
                    }
                    .tag(1)
                
                CalendarPickerView(viewModel: viewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(2)
                
                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(.iosBlue)
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            
            // Permission gate overlay
            if viewModel.authorizationStatus == .notDetermined {
                permissionGate
            } else if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                permissionDeniedGate
            }
        }
    }
    
    // MARK: - Permission Request Gate
    private var permissionGate: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("AlicjaLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 142, height: 142)
                    .padding(20)
                    .background(Color.elevatedCardBackground)
                    .clipShape(.rect(cornerRadius: 34, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.premiumStroke, lineWidth: 1)
                    )
                    .shadow(color: Color.premiumShadow, radius: 24, x: 0, y: 14)
                
                VStack(spacing: 12) {
                    Text("Welcome to Pediglam")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("A minimalist app for managing your free time slots. See available gaps in your workday in seconds.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                
                Button(action: {
                    viewModel.requestAccess()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 15, weight: .bold))

                        Text("Allow Calendar Access")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppStyle.accentGradient)
                    .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
                    .shadow(color: Color.iosBlue.opacity(0.25), radius: 12, x: 0, y: 7)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 36)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
        }
        .transition(.opacity)
    }
    
    // MARK: - Permission Denied Gate
    private var permissionDeniedGate: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(AppStyle.busyGradient)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.busyColor.opacity(0.24), radius: 18, x: 0, y: 10)
                    
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 58, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("Calendar Access Denied")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("Pediglam needs access to your system calendar to display today's appointments and automatically calculate free time.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 15, weight: .bold))

                        Text("Open Settings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppStyle.accentGradient)
                    .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
                    .shadow(color: Color.iosBlue.opacity(0.25), radius: 12, x: 0, y: 7)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 36)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
        }
        .transition(.opacity)
    }
}
