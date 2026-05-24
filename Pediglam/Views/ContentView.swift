import SwiftUI
import EventKit

struct ContentView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil
    @State private var showCreateVisit = false

    private var workHoursText: String {
        let startStr = String(format: "%d:%02d", viewModel.workStartHour, viewModel.workStartMinute)
        let endStr = String(format: "%d:%02d", viewModel.workEndHour, viewModel.workEndMinute)
        return "\(startStr) - \(endStr)"
    }

    var body: some View {
        ZStack {
            PremiumBackground()

            VStack(spacing: 0) {
                PremiumScreenHeader(
                    title: "Day",
                    subtitle: viewModel.selectedDate.formattedPolishHeader(),
                    systemImage: "clock.fill"
                ) {
                    HStack(spacing: 10) {
                        PremiumIconButton(systemName: "plus") {
                            showCreateVisit = true
                        }

                        DatePicker(
                            "",
                            selection: $viewModel.selectedDate,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(.iosBlue)
                    }
                }

                if viewModel.isLoading && viewModel.slots.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(.iosBlue)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            DayOverviewCard(schedule: viewModel.daySchedule, workHours: workHoursText)

                            if viewModel.slots.isEmpty {
                                EmptyStateView()
                                    .frame(minHeight: 360)
                            } else {
                                VStack(alignment: .leading, spacing: 12) {
                                    PremiumSectionTitle(title: "Schedule", trailing: "\(viewModel.slots.count) slots")

                                    LazyVStack(spacing: 12) {
                                        ForEach(viewModel.slots) { slot in
                                            if slot.type == .free {
                                                FreeSlotCard(slot: slot)
                                            } else {
                                                BusySlotCard(slot: slot) {
                                                    if let event = slot.associatedEvent {
                                                        selectedEventDetail = event
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                SummaryView(schedule: viewModel.daySchedule)
                            }
                        }
                        .padding(.horizontal, AppStyle.horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 28)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        viewModel.loadEvents()
                    }
                }
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .sheet(item: $selectedEventDetail) { event in
            EventDetailSheet(event: event)
        }
        .sheet(isPresented: $showCreateVisit) {
            CreateVisitSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }
}

private struct DayOverviewCard: View {
    let schedule: DaySchedule
    let workHours: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppStyle.accentGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.iosBlue.opacity(0.22), radius: 12, x: 0, y: 7)

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Working hours")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondaryText)

                Text(workHours)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("Free")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondaryText)

                Text(schedule.totalFreeTime.formattedDuration())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.freeColor)
                    .lineLimit(1)
            }
        }
        .padding(18)
        .premiumCard(cornerRadius: 24, shadowRadius: 18)
    }
}
