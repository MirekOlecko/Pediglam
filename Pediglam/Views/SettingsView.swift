import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var startPickerDate = Date()
    @State private var endPickerDate = Date()
    @State private var filterNoTitle = false
    @State private var selectedTheme: AppTheme = .system
    
    var body: some View {
        NavigationView {
            Form {
                // Theme
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button(action: {
                            selectedTheme = theme
                            themeManager.theme = theme.rawValue
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: theme.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedTheme == theme ? .iosBlue : .primaryText)
                                    .frame(width: 28)
                                
                                Text(theme.rawValue)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.primaryText)
                                
                                Spacer()
                                
                                if selectedTheme == theme {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.iosBlue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("THEME")
                }
                
                // Working hours
                Section {
                    DatePicker("Start time", selection: $startPickerDate, displayedComponents: .hourAndMinute)
                        .tint(.iosBlue)
                        .onChange(of: startPickerDate) { _ in saveWorkHours() }
                    
                    DatePicker("End time", selection: $endPickerDate, displayedComponents: .hourAndMinute)
                        .tint(.iosBlue)
                        .onChange(of: endPickerDate) { _ in saveWorkHours() }
                } header: {
                    Text("WORKING HOURS")
                }
                
                // Filters
                Section {
                    Toggle("Show clients only", isOn: $filterNoTitle)
                        .tint(.iosBlue)
                        .onChange(of: filterNoTitle) { newValue in
                            viewModel.filterNoTitleEvents = newValue
                        }
                    
                    Text("Hide calendar events that don't have a title/client entered.")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                } header: {
                    Text("FILTERS")
                }
                
                // About
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Pediglam")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Copyright")
                        Spacer()
                        Text("© 2026 Pediglam")
                            .foregroundColor(.secondaryText)
                    }
                } header: {
                    Text("ABOUT")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func loadCurrentSettings() {
        let calendar = Calendar.current
        let today = Date()
        
        startPickerDate = calendar.date(bySettingHour: viewModel.workStartHour, minute: viewModel.workStartMinute, second: 0, of: today) ?? today
        endPickerDate = calendar.date(bySettingHour: viewModel.workEndHour, minute: viewModel.workEndMinute, second: 0, of: today) ?? today
        filterNoTitle = viewModel.filterNoTitleEvents
        selectedTheme = themeManager.currentTheme
    }
    
    private func saveWorkHours() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startPickerDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endPickerDate)
        
        viewModel.workStartHour = startComponents.hour ?? 9
        viewModel.workStartMinute = startComponents.minute ?? 0
        viewModel.workEndHour = endComponents.hour ?? 19
        viewModel.workEndMinute = endComponents.minute ?? 0
    }
}
