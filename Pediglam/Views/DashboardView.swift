import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil
    
    var body: some View {
        ZStack {
            Color.systemBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
            // Header
            HStack {
                Text("Dashboard")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 16)
            
            Divider()
                .background(Color.separator)
            
            // Range filter pills
            rangeFilterBar
            
            Divider()
                .background(Color.separator)
            
            // Content
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
                        // Range label
                        Text(viewModel.dashboardStats.rangeLabel)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Stats grid
                        statsGrid
                            .padding(.horizontal)
                        
                        // Recent visits
                        recentVisits
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
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
    
    // MARK: - Range Filter
    private var rangeFilterBar: some View {
        HStack(spacing: 6) {
            ForEach(CalendarViewModel.DashboardRange.allCases, id: \.self) { range in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.dashboardRange = range
                    }
                }) {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.dashboardRange == range ? .white : .primaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.dashboardRange == range
                                ? Color.iosBlue
                                : Color.cardBackground
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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
                color: .primaryText
            )
        }
    }
    
    // MARK: - Recent Visits
    private var recentVisits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent visits")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .padding(.top, 4)
            
            ForEach(viewModel.dashboardEvents.sorted(by: { $0.startDate > $1.startDate }).prefix(10), id: \.id) { event in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.iosBlue.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(event.clientName.prefix(1).uppercased()))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.iosBlue)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.clientName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primaryText)
                        
                        if let service = event.serviceNote {
                            Text(service)
                                .font(.system(size: 12))
                                .foregroundColor(.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(event.startDate.formattedTime())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primaryText)
                        
                        Text(event.duration.formattedDuration())
                            .font(.system(size: 11))
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(12)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedEventDetail = event
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyDashboard: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            
            ZStack {
                Circle()
                    .fill(Color.freeColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.freeColor)
            }
            
            Text("No visits found")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            
            Text("No appointments in this \(viewModel.dashboardRange.rawValue.lowercased()) range")
                .font(.system(size: 14))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .minimumScaleFactor(0.7)
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}
