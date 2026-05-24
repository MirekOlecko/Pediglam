import Foundation
import Combine
import EventKit

class CalendarViewModel: ObservableObject {
    private let calendarService = CalendarService()

    @Published var slots: [TimeSlot] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var monthEventStartDates: Set<Date> = []

    @Published var selectedDate = Date() {
        didSet {
            loadEvents()
        }
    }

    // True when the user has granted calendar access (handles both iOS 16 .authorized and iOS 17+ .fullAccess)
    private var isAuthorized: Bool {
        if #available(iOS 17.0, *) {
            return authorizationStatus == .fullAccess
        }
        return authorizationStatus == .authorized
    }

    // Generation counters for cancelling stale background fetches
    private var loadEventsGeneration = 0
    private var loadDashboardGeneration = 0

    // MARK: - Settings backed by UserDefaults

    var workStartHour: Int {
        get {
            if UserDefaults.standard.object(forKey: "workStartHour") == nil { return 9 }
            return UserDefaults.standard.integer(forKey: "workStartHour")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "workStartHour")
            objectWillChange.send()
            loadEvents()
        }
    }

    var workStartMinute: Int {
        get {
            UserDefaults.standard.integer(forKey: "workStartMinute")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "workStartMinute")
            objectWillChange.send()
            loadEvents()
        }
    }

    var workEndHour: Int {
        get {
            if UserDefaults.standard.object(forKey: "workEndHour") == nil { return 19 }
            return UserDefaults.standard.integer(forKey: "workEndHour")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "workEndHour")
            objectWillChange.send()
            loadEvents()
        }
    }

    var workEndMinute: Int {
        get {
            UserDefaults.standard.integer(forKey: "workEndMinute")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "workEndMinute")
            objectWillChange.send()
            loadEvents()
        }
    }

    var filterNoTitleEvents: Bool {
        get {
            UserDefaults.standard.bool(forKey: "filterNoTitleEvents")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "filterNoTitleEvents")
            objectWillChange.send()
            loadEvents()
        }
    }

    // MARK: - Dashboard Stats

    enum DashboardRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    @Published var dashboardRange: DashboardRange = .week {
        didSet {
            UserDefaults.standard.set(dashboardRange.rawValue, forKey: "dashboardRange")
        }
    }
    @Published var dashboardEvents: [CalendarEvent] = []
    @Published var dashboardIsLoading = false

    struct DashboardStats {
        let totalVisits: Int
        let uniqueClients: Int
        let totalBusyMinutes: Int
        let totalFreeMinutes: Int
        let occupancyRate: Double
        let rangeLabel: String
    }

    var daySchedule: DaySchedule {
        DaySchedule(date: selectedDate, slots: slots)
    }

    var dashboardStats: DashboardStats {
        let calendar = Calendar.current
        let now = Date()

        let (rangeStart, rangeEnd): (Date, Date) = {
            switch dashboardRange {
            case .day:
                return (calendar.startOfDay(for: now),
                        calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: now))!)
            case .week:
                let weekday = calendar.component(.weekday, from: now)
                let mondayOffset = (weekday + 5) % 7
                let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: calendar.startOfDay(for: now))!
                return (monday,
                        calendar.date(byAdding: DateComponents(day: 7, second: -1), to: monday)!)
            case .month:
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                return (startOfMonth,
                        calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)!)
            case .year:
                let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
                return (startOfYear,
                        calendar.date(byAdding: DateComponents(year: 1, second: -1), to: startOfYear)!)
            }
        }()

        // Clip each event to both the date range AND the daily work hours window
        let busyMinutes = dashboardEvents.reduce(0) { total, event in
            let eventStart = max(event.startDate, rangeStart)
            let eventEnd = min(event.endDate, rangeEnd)
            guard eventStart < eventEnd else { return total }

            var minutes = 0
            var day = calendar.startOfDay(for: eventStart)
            let lastDay = calendar.startOfDay(for: eventEnd)
            while day <= lastDay {
                if let workStart = calendar.date(bySettingHour: workStartHour, minute: workStartMinute, second: 0, of: day),
                   let workEnd = calendar.date(bySettingHour: workEndHour, minute: workEndMinute, second: 0, of: day) {
                    let overlapStart = max(eventStart, workStart)
                    let overlapEnd = min(eventEnd, workEnd)
                    if overlapStart < overlapEnd {
                        minutes += Int(overlapEnd.timeIntervalSince(overlapStart) / 60)
                    }
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
            return total + minutes
        }

        let workingDays: Int = {
            let days = calendar.dateComponents([.day], from: rangeStart, to: rangeEnd).day ?? 0
            return days + 1
        }()
        // Include minutes in work day length (e.g. 9:30–18:30 = 540 min, not 9*60)
        let workMinutesPerDay = (workEndHour * 60 + workEndMinute) - (workStartHour * 60 + workStartMinute)
        let totalWorkMinutes = workingDays * workMinutesPerDay
        let freeMinutes = max(0, totalWorkMinutes - busyMinutes)

        let clients = Set(dashboardEvents.map { $0.clientName })

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        return DashboardStats(
            totalVisits: dashboardEvents.count,
            uniqueClients: clients.count,
            totalBusyMinutes: busyMinutes,
            totalFreeMinutes: freeMinutes,
            occupancyRate: totalWorkMinutes > 0 ? Double(busyMinutes) / Double(totalWorkMinutes) : 0,
            rangeLabel: "\(formatter.string(from: rangeStart)) – \(formatter.string(from: rangeEnd))"
        )
    }

    func loadDashboardEvents() {
        authorizationStatus = calendarService.checkAuthorizationStatus()
        guard isAuthorized else { return }

        dashboardIsLoading = true
        loadDashboardGeneration += 1
        let generation = loadDashboardGeneration

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let (start, end) = self.dashboardDateRange()
            let events = self.calendarService.fetchEvents(from: start, to: end)
            let filtered = events.filter { event in
                if event.isAllDay { return false }
                let title = event.title ?? ""
                if self.filterNoTitleEvents && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return false
                }
                return true
            }
            let wrapped = filtered.map { CalendarEvent(ekEvent: $0) }

            DispatchQueue.main.async {
                guard self.loadDashboardGeneration == generation else { return }
                self.dashboardEvents = wrapped
                self.dashboardIsLoading = false
            }
        }
    }

    func loadMonthEvents(month: Date) {
        guard isAuthorized else { return }
        let cal = Calendar.current
        guard let start = cal.date(from: cal.dateComponents([.year, .month], from: month)),
              let end = cal.date(byAdding: DateComponents(month: 1, second: -1), to: start) else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            let events = self.calendarService.fetchEvents(from: start, to: end)
            let dates = Set(events.filter { !$0.isAllDay }.map { cal.startOfDay(for: $0.startDate) })
            DispatchQueue.main.async {
                self.monthEventStartDates = dates
            }
        }
    }

    private func dashboardDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        switch dashboardRange {
        case .day:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
            return (start, end)
        case .week:
            let weekday = calendar.component(.weekday, from: now)
            let mondayOffset = (weekday + 5) % 7
            let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: calendar.startOfDay(for: now))!
            let end = calendar.date(byAdding: DateComponents(day: 7, second: -1), to: monday)!
            return (monday, end)
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
            return (start, end)
        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start)!
            return (start, end)
        }
    }

    init() {
        self.authorizationStatus = calendarService.checkAuthorizationStatus()
        if let saved = UserDefaults.standard.string(forKey: "dashboardRange"),
           let range = DashboardRange(rawValue: saved) {
            self.dashboardRange = range
        }
    }

    func requestAccess() {
        calendarService.requestAccess { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let granted):
                // Re-read the real status rather than hardcoding .authorized (iOS 17+ returns .fullAccess)
                self.authorizationStatus = self.calendarService.checkAuthorizationStatus()
                if granted {
                    self.loadEvents()
                    self.loadDashboardEvents()
                } else {
                    self.error = "Calendar access denied."
                }
            case .failure(let err):
                self.authorizationStatus = self.calendarService.checkAuthorizationStatus()
                self.error = "Authorization error: \(err.localizedDescription)"
            }
        }
    }

    // MARK: - Write Operations

    func conflictingEvents(start: Date, end: Date) -> [CalendarEvent] {
        let events = calendarService.fetchEvents(from: start, to: end)
        return events
            .filter { !$0.isAllDay }
            .filter { event in
                event.startDate < end && event.endDate > start
            }
            .map { CalendarEvent(ekEvent: $0) }
    }

    func createVisit(clientName: String, date: Date, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, serviceNote: String?) -> Bool {
        let calendar = Calendar.current

        guard let startDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: date),
              let endDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date),
              endDate > startDate else {
            return false
        }

        let conflicts = conflictingEvents(start: startDate, end: endDate)
        if !conflicts.isEmpty {
            self.error = "Time conflict with: \(conflicts.map { "\($0.clientName) (\($0.startDate.formattedTime())–\($0.endDate.formattedTime()))" }.joined(separator: ", "))"
            return false
        }

        let timeStr = String(format: "%d:%02d", startHour, startMinute)
        var title = "\(clientName) \(timeStr)"
        if let note = serviceNote, !note.trimmingCharacters(in: .whitespaces).isEmpty {
            title += " \(note)"
        }

        do {
            _ = try calendarService.createEvent(title: title, startDate: startDate, endDate: endDate)
            loadEvents()
            loadDashboardEvents()
            return true
        } catch {
            self.error = "Failed to create visit: \(error.localizedDescription)"
            return false
        }
    }

    func deleteVisit(_ event: CalendarEvent) {
        do {
            try calendarService.deleteEvent(event.ekEvent)
            loadEvents()
            loadDashboardEvents()
        } catch {
            self.error = "Failed to delete visit: \(error.localizedDescription)"
        }
    }

    func loadEvents() {
        authorizationStatus = calendarService.checkAuthorizationStatus()
        guard isAuthorized else { return }

        isLoading = true
        error = nil
        loadEventsGeneration += 1
        let generation = loadEventsGeneration
        let dateSnapshot = selectedDate

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let fetchedEvents = self.calendarService.fetchEvents(for: dateSnapshot)
            let calculatedSlots = self.calculateSlots(events: fetchedEvents, for: dateSnapshot)

            DispatchQueue.main.async {
                guard self.loadEventsGeneration == generation else { return }
                self.slots = calculatedSlots
                self.isLoading = false
            }
        }
    }

    private func calculateSlots(events: [EKEvent], for date: Date) -> [TimeSlot] {
        let calendar = Calendar.current

        guard let workStart = calendar.date(bySettingHour: workStartHour, minute: workStartMinute, second: 0, of: date),
              let workEnd = calendar.date(bySettingHour: workEndHour, minute: workEndMinute, second: 0, of: date),
              workStart < workEnd else {
            return []
        }

        // 1. Filter out all-day events and those outside work hours
        let filteredEvents = events.filter { event in
            if event.isAllDay { return false }
            let title = event.title ?? ""
            if filterNoTitleEvents && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
            return event.startDate < workEnd && event.endDate > workStart
        }

        // 2. Sort by start date
        let sortedEvents = filteredEvents.sorted { $0.startDate < $1.startDate }

        // 3. Clamp events to work hours and merge overlaps, preserving all events in each merged slot
        var busySlots: [TimeSlot] = []
        for event in sortedEvents {
            let wrapped = CalendarEvent(ekEvent: event)
            let start = max(event.startDate, workStart)
            let end = min(event.endDate, workEnd)

            if start < end {
                if let last = busySlots.last, start <= last.endDate {
                    // Overlap — merge into previous slot, keeping all associated events
                    let mergedEnd = max(last.endDate, end)
                    let mergedTitle = last.title == wrapped.clientName
                        ? last.title
                        : "\(last.title), \(wrapped.clientName)"
                    busySlots.removeLast()
                    busySlots.append(TimeSlot(
                        startDate: last.startDate,
                        endDate: mergedEnd,
                        type: .busy,
                        title: mergedTitle,
                        associatedEvents: last.associatedEvents + [wrapped]
                    ))
                } else {
                    busySlots.append(TimeSlot(startDate: start, endDate: end, type: .busy, title: wrapped.clientName, associatedEvent: wrapped))
                }
            }
        }

        // 4. Fill gaps between busy slots with free slots
        var allSlots: [TimeSlot] = []
        var currentPointer = workStart

        for busy in busySlots {
            if currentPointer < busy.startDate {
                allSlots.append(TimeSlot(startDate: currentPointer, endDate: busy.startDate, type: .free, title: "Free"))
            }
            allSlots.append(busy)
            currentPointer = max(currentPointer, busy.endDate)
        }

        if currentPointer < workEnd {
            allSlots.append(TimeSlot(startDate: currentPointer, endDate: workEnd, type: .free, title: "Free"))
        }

        return allSlots
    }
}
