import SwiftUI
import EventKit

struct CalendarPickerView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil
    @State private var showCreateVisit = false
    @State private var calendarExpanded = true
    @State private var displayedMonth = Date()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            PremiumBackground()

            VStack(spacing: 0) {
                PremiumScreenHeader(
                    title: "Calendar",
                    subtitle: viewModel.selectedDate.formattedPolishHeader(),
                    systemImage: "calendar"
                ) {
                    PremiumIconButton(systemName: "plus") {
                        showCreateVisit = true
                    }
                }

                ScrollView {
                    VStack(spacing: 16) {
                        calendarCard

                        calendarContentBelow
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 2)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.loadEvents()
                    viewModel.loadMonthEvents(month: displayedMonth)
                }
            }
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .sheet(item: $selectedEventDetail) { event in
            EventDetailSheet(event: event)
        }
        .sheet(isPresented: $showCreateVisit) {
            CreateVisitSheet(viewModel: viewModel)
        }
        .onAppear {
            displayedMonth = viewModel.selectedDate
            viewModel.loadEvents()
            viewModel.loadMonthEvents(month: viewModel.selectedDate)
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            if !calendar.isDate(newDate, equalTo: displayedMonth, toGranularity: .month) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayedMonth = newDate
                }
            }
        }
        .onChange(of: displayedMonth) { newMonth in
            viewModel.loadMonthEvents(month: newMonth)
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            calendarTopBar

            if calendarExpanded {
                fullCalendar
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .premiumCard(cornerRadius: 26, shadowRadius: 18)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: calendarExpanded)
    }

    private var calendarTopBar: some View {
        HStack(spacing: 12) {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.iosBlue)
                    .frame(width: 34, height: 34)
                    .background(Color.iosBlue.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    calendarExpanded.toggle()
                }
            } label: {
                VStack(spacing: 2) {
                    Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)

                    Text(calendarExpanded ? "Tap to compact" : "Tap to expand")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.iosBlue)
                    .frame(width: 34, height: 34)
                    .background(Color.iosBlue.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var fullCalendar: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.selectedDate = Date()
                        displayedMonth = Date()
                    }
                } label: {
                    Text("Today")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(calendar.isDateInToday(viewModel.selectedDate) ? .white : .iosBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(calendar.isDateInToday(viewModel.selectedDate) ? AnyShapeStyle(AppStyle.accentGradient) : AnyShapeStyle(Color.iosBlue.opacity(0.10)))
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(viewModel.selectedDate.formattedShortDate())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            HStack(spacing: 4) {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(day == "Sat" || day == "Sun" ? .secondaryText.opacity(0.72) : .secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, date in
                    if let date {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                                viewModel.selectedDate = date
                            }
                        } label: {
                            EnhancedDayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                                isToday: calendar.isDateInToday(date),
                                isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                                hasEvents: checkHasEvents(for: date)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }
        }
    }

    private var calendarContentBelow: some View {
        VStack(alignment: .leading, spacing: 12) {
            PremiumSectionTitle(title: "Selected day", trailing: "\(viewModel.slots.count) slots")

            if viewModel.isLoading && viewModel.slots.isEmpty {
                ProgressView()
                    .tint(.iosBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if viewModel.slots.isEmpty {
                compactEmptyState
            } else {
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

                SummaryView(schedule: viewModel.daySchedule)
            }
        }
    }

    private var compactEmptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppStyle.freeGradient)
                    .frame(width: 68, height: 68)
                    .shadow(color: Color.freeColor.opacity(0.22), radius: 14, x: 0, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("No appointments this day")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)

            Text("Your working window is fully open.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .premiumCard(cornerRadius: 22, shadowRadius: 12)
    }

    private var dayHeaders: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    private func shiftMonth(_ delta: Int) {
        withAnimation(.easeInOut(duration: 0.25)) {
            displayedMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
        }
    }

    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    private func checkHasEvents(for date: Date) -> Bool {
        viewModel.monthEventStartDates.contains(calendar.startOfDay(for: date))
    }
}

struct EnhancedDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasEvents: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppStyle.accentGradient) : AnyShapeStyle(Color.softFill.opacity(isToday ? 1 : 0)))
                    .frame(height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isToday && !isSelected ? Color.iosBlue.opacity(0.35) : Color.clear, lineWidth: 1.5)
                    )

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .semibold, design: .rounded))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? .iosBlue :
                        isCurrentMonth ? .primaryText : .secondaryText.opacity(0.35)
                    )
            }

            Circle()
                .fill(hasEvents && !isSelected ? Color.iosBlue.opacity(0.72) : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(height: 48)
        .contentShape(Rectangle())
    }
}
