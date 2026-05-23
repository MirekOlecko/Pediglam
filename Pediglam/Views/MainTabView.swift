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
                
                ContentView(viewModel: viewModel, showSettings: .constant(false))
                    .tabItem {
                        Label("Day", systemImage: "clock")
                    }
                    .tag(1)
                
                CalendarPickerView(viewModel: viewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(2)
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
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("AlicjaLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                VStack(spacing: 12) {
                    Text("Welcome to Pediglam")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("A minimalist app for managing your free time slots. See available gaps in your workday in seconds.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                
                Button(action: {
                    viewModel.requestAccess()
                }) {
                    Text("Allow Calendar Access")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.iosBlue)
                        .cornerRadius(14)
                        .shadow(color: Color.iosBlue.opacity(0.2), radius: 8, x: 0, y: 4)
                }
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
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.busyColor.opacity(0.1))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.busyColor)
                }
                
                VStack(spacing: 12) {
                    Text("Calendar Access Denied")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                    
                    Text("Pediglam needs access to your system calendar to display today's appointments and automatically calculate free time.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.iosBlue)
                        .cornerRadius(14)
                        .shadow(color: Color.iosBlue.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 36)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
        }
        .transition(.opacity)
    }
}
