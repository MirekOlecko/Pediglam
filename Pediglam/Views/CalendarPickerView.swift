import SwiftUI
import EventKit

struct CalendarPickerView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil
    @State private var showCreateVisit = false
    
    @State private var rotationDegree: Double = 0.0
    @State private var displayedMonth = Date()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select Date")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: { showCreateVisit = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.iosBlue)
                        .padding(.trailing, 6)
                }
                
                Button(action: {
                    withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                        rotationDegree = 360.0
                    }
                    viewModel.loadEvents()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.iosBlue)
                        .padding(8)
                        .background(Color.iosBlue.opacity(0.08))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(rotationDegree))
                }
                .onChange(of: viewModel.isLoading) { loading in
                    if !loading {
                        withAnimation(.linear(duration: 0.3)) {
                            rotationDegree = 0.0
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 12)
            
            // Calendar card
            calendarCard
            
            Divider()
                .background(Color.separator)
            
            // Content below calendar
            calendarContentBelow
        }
        .background(Color.systemBackground)
        .sheet(item: $selectedEventDetail) { event in
            EventDetailSheet(event: event)
        }
        .sheet(isPresented: $showCreateVisit) {
            CreateVisitSheet(viewModel: viewModel)
        }
        .onAppear {
            displayedMonth = viewModel.selectedDate
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            if !calendar.isDate(newDate, inSameDayAs: displayedMonth) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayedMonth = newDate
                }
            }
        }
    }
    
    // MARK: - Calendar Card
    private var calendarCard: some View {
        VStack(spacing: 0) {
            // Month navigation — compact pills
            HStack(spacing: 0) {
                Button(action: { shiftMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.iosBlue)
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
                
                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .id("month-\(displayedMonth.timeIntervalSince1970)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                Spacer()
                
                Button(action: { shiftMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.iosBlue)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Today quick-jump
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectedDate = Date()
                        displayedMonth = Date()
                    }
                }) {
                    Text("Today")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(calendar.isDate(Date(), inSameDayAs: viewModel.selectedDate) ? .white : .iosBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(
                            calendar.isDate(Date(), inSameDayAs: viewModel.selectedDate)
                                ? Color.iosBlue
                                : Color.iosBlue.opacity(0.1)
                        )
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Text(viewModel.selectedDate.formattedPolishHeader())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            Divider()
                .background(Color.separator)
                .padding(.horizontal, 20)
            
            // Day headers
            HStack(spacing: 2) {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(day == "Sat" || day == "Sun" ? .secondaryText.opacity(0.7) : .secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        EnhancedDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                            hasEvents: checkHasEvents(for: date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    // MARK: - Content Below Calendar
    private var calendarContentBelow: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.slots.isEmpty {
                Spacer().frame(height: 40)
                ProgressView()
                    .tint(.iosBlue)
            } else if viewModel.slots.isEmpty {
                Spacer().frame(height: 24)
                compactEmptyState
            } else {
                ScrollView {
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
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    viewModel.loadEvents()
                }
                
                Divider()
                    .background(Color.separator)
                
                SummaryView(schedule: viewModel.daySchedule)
                    .padding(.vertical, 12)
                    .background(Color.systemBackground)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Compact Empty State
    private var compactEmptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.freeColor.opacity(0.08))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.freeColor)
            }
            
            Text("No appointments this day")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondaryText)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helpers
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
        return calendar.isDateInToday(date)
    }
}

// MARK: - Enhanced Day Cell
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
                // Selection background
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.iosBlue : Color.clear)
                    .frame(width: 36, height: 36)
                
                // Today ring
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.iosBlue.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                }
                
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 15, weight: isSelected ? .bold : (isToday ? .semibold : .regular), design: .rounded))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? .iosBlue :
                        isCurrentMonth ? .primaryText : .secondaryText.opacity(0.35)
                    )
            }
            
            // Event indicator dot
            if hasEvents && !isSelected {
                Circle()
                    .fill(Color.iosBlue.opacity(0.6))
                    .frame(width: 4, height: 4)
            } else {
                Spacer().frame(height: 4)
            }
        }
        .frame(height: 46)
        .contentShape(Rectangle())
    }
}
