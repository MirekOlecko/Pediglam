import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil

    var body: some View {
        ZStack {
            PremiumBackground()

            VStack(spacing: 0) {
                PremiumScreenHeader(
                    title: "Dashboard",
                    subtitle: viewModel.dashboardStats.rangeLabel,
                    systemImage: "rectangle.split.2x2.fill"
                )

                rangeFilterBar

                if viewModel.dashboardIsLoading {
                    Spacer()
                    ProgressView()
                        .tint(.iosBlue)
                    Spacer()
                } else if viewModel.dashboardEvents.isEmpty {
                    emptyDashboard
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            DashboardHeroCard(stats: viewModel.dashboardStats)

                            statsGrid

                            recentVisits
                        }
                        .padding(.horizontal, AppStyle.horizontalPadding)
                        .padding(.top, 14)
                        .padding(.bottom, 28)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .onAppear {
            viewModel.loadDashboardEvents()
        }
        .onChange(of: viewModel.dashboardRange) { _ in
            viewModel.loadDashboardEvents()
        }
        .onChange(of: viewModel.authorizationStatus) { status in
            if status == .authorized {
                viewModel.loadDashboardEvents()
            }
        }
        .sheet(item: $selectedEventDetail) { event in
            EventDetailSheet(event: event)
        }
    }

    private var rangeFilterBar: some View {
        HStack(spacing: 8) {
            ForEach(CalendarViewModel.DashboardRange.allCases, id: \.self) { range in
                let isSelected = viewModel.dashboardRange == range

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.dashboardRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? AnyShapeStyle(AppStyle.accentGradient) : AnyShapeStyle(Color.elevatedCardBackground))
                        .clipShape(.rect(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color.premiumStroke, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppStyle.horizontalPadding)
        .padding(.bottom, 4)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Visits",
                value: "\(viewModel.dashboardStats.totalVisits)",
                subtitle: "\(viewModel.dashboardStats.uniqueClients) clients",
                icon: "person.2.fill",
                color: .iosBlue
            )

            StatCard(
                title: "Busy",
                value: TimeInterval(Double(viewModel.dashboardStats.totalBusyMinutes) * 60).formattedDuration(),
                subtitle: "scheduled",
                icon: "clock.fill",
                color: .busyColor
            )

            StatCard(
                title: "Free",
                value: TimeInterval(Double(viewModel.dashboardStats.totalFreeMinutes) * 60).formattedDuration(),
                subtitle: "available",
                icon: "checkmark.circle.fill",
                color: .freeColor
            )

            StatCard(
                title: "Occupancy",
                value: String(format: "%.0f%%", viewModel.dashboardStats.occupancyRate * 100),
                subtitle: "fill rate",
                icon: "chart.bar.fill",
                color: .premiumGold
            )
        }
    }

    private var recentVisits: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Recent visits", trailing: "\(min(viewModel.dashboardEvents.count, 10)) shown")

            ForEach(viewModel.dashboardEvents.sorted(by: { $0.startDate > $1.startDate }).prefix(10), id: \.id) { event in
                Button {
                    selectedEventDetail = event
                } label: {
                    VisitRow(event: event)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyDashboard: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppStyle.freeGradient)
                    .frame(width: 92, height: 92)
                    .shadow(color: Color.freeColor.opacity(0.24), radius: 18, x: 0, y: 10)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("No visits found")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text("No appointments in this \(viewModel.dashboardRange.rawValue.lowercased()) range")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

private struct DashboardHeroCard: View {
    let stats: CalendarViewModel.DashboardStats

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Fill rate")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.secondaryText)

                    Text(String(format: "%.0f%%", stats.occupancyRate * 100))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.premiumGold)
                    .padding(12)
                    .background(Color.premiumGold.opacity(0.12))
                    .clipShape(Circle())
            }

            ProgressView(value: min(max(stats.occupancyRate, 0), 1))
                .tint(.iosBlue)
                .frame(height: 8)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)

            HStack {
                HeroMetric(label: "Busy", value: TimeInterval(Double(stats.totalBusyMinutes) * 60).formattedDuration(), color: .busyColor)
                Spacer()
                HeroMetric(label: "Free", value: TimeInterval(Double(stats.totalFreeMinutes) * 60).formattedDuration(), color: .freeColor, alignment: .trailing)
            }
        }
        .padding(20)
        .premiumCard(cornerRadius: 26, shadowRadius: 20)
    }
}

private struct HeroMetric: View {
    let label: String
    let value: String
    let color: Color
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondaryText)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())

                Spacer()
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .minimumScaleFactor(0.7)

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondaryText)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText.opacity(0.82))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 122, alignment: .leading)
        .padding(16)
        .premiumCard(cornerRadius: 20, shadowRadius: 12)
    }
}

private struct VisitRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            Text(String(event.clientName.prefix(1).uppercased()))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(AppStyle.accentGradient)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(event.clientName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)

                if let service = event.serviceNote {
                    Text(service)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                } else {
                    Text(event.startDate.formattedShortDate())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(event.startDate.formattedTime())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text(event.duration.formattedDuration())
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondaryText.opacity(0.35))
        }
        .padding(14)
        .premiumCard(cornerRadius: 18, shadowRadius: 10)
    }
}
