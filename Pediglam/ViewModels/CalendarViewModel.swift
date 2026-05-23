import Foundation
import Combine
import EventKit

class CalendarViewModel: ObservableObject {
    private let calendarService = CalendarService()
    
    @Published var slots: [TimeSlot] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var selectedDate = Date() {
        didSet {
            loadEvents()
        }
    }
    
    // Settings backed by UserDefaults with published notifications
    var workStartHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: "workStartHour")
            return val == 0 ? 9 : val
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
            let val = UserDefaults.standard.integer(forKey: "workEndHour")
            return val == 0 ? 19 : val
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
    
    @Published var dashboardRange: DashboardRange = .week
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
        
        let busyMinutes = dashboardEvents.reduce(0) { acc, event in
            let start = max(event.startDate, rangeStart)
            let end = min(event.endDate, rangeEnd)
            return acc + Int(max(0, end.timeIntervalSince(start)) / 60)
        }
        
        let workingDays: Int = {
            let days = calendar.dateComponents([.day], from: rangeStart, to: rangeEnd).day ?? 0
            return days + 1
        }()
        let workMinutesPerDay = (workEndHour - workStartHour) * 60
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
        guard authorizationStatus == .authorized else { return }
        
        dashboardIsLoading = true
        
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
                self.dashboardEvents = wrapped
                self.dashboardIsLoading = false
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
    }
    
    func requestAccess() {
        calendarService.requestAccess { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let granted):
                self.authorizationStatus = granted ? .authorized : .denied
                if granted {
                    self.loadEvents()
                    self.loadDashboardEvents()
                } else {
                    self.error = "Calendar access denied."
                }
            case .failure(let err):
                self.authorizationStatus = .denied
                    self.error = "Authorization error: \(err.localizedDescription)"
            }
        }
    }
    
    // MARK: - Write Operations
    
    func createVisit(clientName: String, date: Date, hour: Int, minute: Int, durationMinutes: Int, serviceNote: String?) {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date),
              let endDate = calendar.date(byAdding: .minute, value: durationMinutes, to: startDate) else {
            return
        }
        
        // Format title: "ClientName HH:MM serviceNote"
        let timeStr = String(format: "%d:%02d", hour, minute)
        var title = "\(clientName) \(timeStr)"
        if let note = serviceNote, !note.trimmingCharacters(in: .whitespaces).isEmpty {
            title += " \(note)"
        }
        
        do {
            _ = try calendarService.createEvent(title: title, startDate: startDate, endDate: endDate)
            loadEvents()
            loadDashboardEvents()
        } catch {
            self.error = "Failed to create visit: \(error.localizedDescription)"
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
        self.authorizationStatus = calendarService.checkAuthorizationStatus()
        guard authorizationStatus == .authorized else {
            return
        }
        
        isLoading = true
        error = nil
        
        // Simulating pull to refresh delay slightly for premium feel or direct fetch
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fetchedEvents = self.calendarService.fetchEvents(for: self.selectedDate)
            
            // Build the slots using the algorithm
            let calculatedSlots = self.calculateSlots(events: fetchedEvents)
            
            DispatchQueue.main.async {
                self.slots = calculatedSlots
                self.isLoading = false
            }
        }
    }
    
    private func calculateSlots(events: [EKEvent]) -> [TimeSlot] {
        let calendar = Calendar.current
        
        // Define workStart and workEnd Date bounds for the selectedDate
        guard let workStart = calendar.date(bySettingHour: workStartHour, minute: workStartMinute, second: 0, of: selectedDate),
              let workEnd = calendar.date(bySettingHour: workEndHour, minute: workEndMinute, second: 0, of: selectedDate),
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
            
            // Event must start before workEnd AND end after workStart
            return event.startDate < workEnd && event.endDate > workStart
        }
        
        // 2. Sort by start date
        let sortedEvents = filteredEvents.sorted { $0.startDate < $1.startDate }
        
        // 3. Clamp events and merge overlaps
        var busySlots: [TimeSlot] = []
        for event in sortedEvents {
            let wrapped = CalendarEvent(ekEvent: event)
            let start = max(event.startDate, workStart)
            let end = min(event.endDate, workEnd)
            
            if start < end {
                if let last = busySlots.last {
                    if start <= last.endDate {
                        // Overlap found, merge them
                        let mergedEnd = max(last.endDate, end)
                        let mergedTitle = last.title == wrapped.clientName ? last.title : "\(last.title), \(wrapped.clientName)"
                        busySlots.removeLast()
                        busySlots.append(TimeSlot(startDate: last.startDate, endDate: mergedEnd, type: .busy, title: mergedTitle, associatedEvent: wrapped))
                    } else {
                        busySlots.append(TimeSlot(startDate: start, endDate: end, type: .busy, title: wrapped.clientName, associatedEvent: wrapped))
                    }
                } else {
                    busySlots.append(TimeSlot(startDate: start, endDate: end, type: .busy, title: wrapped.clientName, associatedEvent: wrapped))
                }
            }
        }
        
        // 4. Calculate free slots between busy slots
        var allSlots: [TimeSlot] = []
        var currentPointer = workStart
        
        for busy in busySlots {
            if currentPointer < busy.startDate {
                // There is a free slot before this busy slot
                allSlots.append(TimeSlot(startDate: currentPointer, endDate: busy.startDate, type: .free, title: "Free"))
            }
            allSlots.append(busy)
            currentPointer = max(currentPointer, busy.endDate)
        }
        
        if currentPointer < workEnd {
            // There is a free slot at the end of the work day
                allSlots.append(TimeSlot(startDate: currentPointer, endDate: workEnd, type: .free, title: "Free"))
        }
        
        return allSlots
    }
}
