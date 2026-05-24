import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var startPickerDate = Date()
    @State private var endPickerDate = Date()
    @State private var filterNoTitle = false
    @State private var selectedTheme: AppTheme = .system
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        sheetIntro
                        themeSection
                        workingHoursSection
                        filtersSection
                        aboutSection
                        saveButton
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondaryText)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }

    private var sheetIntro: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppStyle.accentGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.iosBlue.opacity(0.22), radius: 12, x: 0, y: 7)

                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Preferences")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text("Tune the calendar experience")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            Spacer()
        }
        .padding(18)
        .premiumCard(cornerRadius: 24, shadowRadius: 16)
    }

    private var themeSection: some View {
        PremiumSettingsSection(title: "Theme") {
            VStack(spacing: 0) {
                ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { index, theme in
                    Button {
                        selectedTheme = theme
                    } label: {
                        HStack(spacing: 12) {
                            SettingsRowIcon(systemName: theme.icon, color: selectedTheme == theme ? .iosBlue : .secondaryText)

                            Text(theme.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primaryText)

                            Spacer()

                            if selectedTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.iosBlue)
                            }
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < AppTheme.allCases.count - 1 {
                        PremiumRowDivider()
                    }
                }
            }
        }
    }

    private var workingHoursSection: some View {
        PremiumSettingsSection(title: "Working hours") {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "sunrise.fill", color: .premiumGold)

                    DatePicker("Start time", selection: $startPickerDate, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "moon.stars.fill", color: .iosBlue)

                    DatePicker("End time", selection: $endPickerDate, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)
            }
        }
    }

    private var filtersSection: some View {
        PremiumSettingsSection(title: "Filters") {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "line.3.horizontal.decrease.circle.fill", color: .freeColor)

                    Toggle("Show clients only", isOn: $filterNoTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)

                PremiumRowDivider()

                Text("Hide calendar events that don't have a title/client entered.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
        }
    }

    private var aboutSection: some View {
        PremiumSettingsSection(title: "About") {
            VStack(spacing: 0) {
                PremiumInfoRow(title: "Name", value: "Pediglam", icon: "app.badge.fill", color: .iosBlue)
                PremiumRowDivider()
                PremiumInfoRow(title: "Version", value: "1.0.0", icon: "number.circle.fill", color: .premiumGold)
                PremiumRowDivider()
                PremiumInfoRow(title: "Copyright", value: "© 2026 Pediglam", icon: "c.circle.fill", color: .secondaryText)
            }
        }
    }

    private var saveButton: some View {
        Button {
            saveSettings()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))

                Text("Save changes")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(AppStyle.accentGradient)
            .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
            .shadow(color: Color.iosBlue.opacity(0.25), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
    
    private func loadCurrentSettings() {
        let calendar = Calendar.current
        let today = Date()
        
        startPickerDate = calendar.date(bySettingHour: viewModel.workStartHour, minute: viewModel.workStartMinute, second: 0, of: today) ?? today
        endPickerDate = calendar.date(bySettingHour: viewModel.workEndHour, minute: viewModel.workEndMinute, second: 0, of: today) ?? today
        filterNoTitle = viewModel.filterNoTitleEvents
        selectedTheme = themeManager.currentTheme
    }
    
    private func saveSettings() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startPickerDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endPickerDate)
        
        viewModel.workStartHour = startComponents.hour ?? 9
        viewModel.workStartMinute = startComponents.minute ?? 0
        viewModel.workEndHour = endComponents.hour ?? 19
        viewModel.workEndMinute = endComponents.minute ?? 0
        viewModel.filterNoTitleEvents = filterNoTitle
        themeManager.theme = selectedTheme.rawValue
    }
}
