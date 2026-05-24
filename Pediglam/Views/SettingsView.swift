import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var startPickerDate = Date()
    @State private var endPickerDate = Date()
    @State private var filterNoTitle = false
    @State private var selectedTheme: AppTheme = .system
    
    var body: some View {
        ZStack {
            PremiumBackground()

            VStack(spacing: 0) {
                PremiumScreenHeader(
                    title: "Settings",
                    subtitle: "Theme, hours and filters",
                    systemImage: "gearshape.fill"
                )

                ScrollView {
                    VStack(spacing: 16) {
                        themeSection
                        workingHoursSection
                        filtersSection
                        aboutSection
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            loadCurrentSettings()
        }
    }

    private var themeSection: some View {
        PremiumSettingsSection(title: "Theme") {
            VStack(spacing: 0) {
                ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { index, theme in
                    Button {
                        selectedTheme = theme
                        themeManager.theme = theme.rawValue
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
                        .onChange(of: startPickerDate) { _ in saveWorkHours() }
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "moon.stars.fill", color: .iosBlue)

                    DatePicker("End time", selection: $endPickerDate, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                        .onChange(of: endPickerDate) { _ in saveWorkHours() }
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
                        .onChange(of: filterNoTitle) { newValue in
                            viewModel.filterNoTitleEvents = newValue
                        }
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

struct PremiumSettingsSection<Content: View>: View {
    let title: String
    let trailing: String?
    let content: Content

    init(title: String, trailing: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.trailing = trailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PremiumSectionTitle(title: title, trailing: trailing)
                .padding(.horizontal, 2)

            content
                .premiumCard(cornerRadius: 22, shadowRadius: 12)
        }
    }
}

struct SettingsRowIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(color)
            .frame(width: 34, height: 34)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
}

struct PremiumRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.premiumStroke)
            .frame(height: 1)
            .padding(.leading, 60)
    }
}

struct PremiumInfoRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            SettingsRowIcon(systemName: icon, color: color)

            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
    }
}
