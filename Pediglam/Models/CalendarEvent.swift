import Foundation
import EventKit

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    
    /// Raw title from EventKit (e.g. "Dorotka 10:50" or "Martinka  15:00 rece manicure , nogi")
    let rawTitle: String
    
    /// Cleaned client name — strips embedded time patterns (e.g. "Dorotka 10:50" → "Dorotka")
    let clientName: String
    
    /// Optional service note extracted after embedded time (e.g. "rece manicure, nogi")
    let serviceNote: String?
    
    let startDate: Date
    let endDate: Date
    let notes: String?
    let location: String?
    let ekEvent: EKEvent
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    init(ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.ekEvent = ekEvent
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.notes = ekEvent.notes
        self.location = ekEvent.location
        
        let raw = ekEvent.title ?? ""
        let parsed = CalendarEvent.parseTitle(raw)
        
        /// Display title: clientName if available, else rawTitle, else "Busy"
        self.rawTitle = raw.isEmpty ? "Busy" : raw
        self.clientName = parsed.name.isEmpty ? "Busy" : parsed.name
        self.serviceNote = parsed.service
    }
    
    // MARK: - Title Parsing
    
    /// Parses titles like:
    ///   "Dorotka 10:50"             → name: "Dorotka",          service: nil
    ///   "Mum cristina 17:15"        → name: "Mum cristina",     service: nil
    ///   "Martinka  15:00 rece manicure , nogi" → name: "Martinka", service: "rece manicure, nogi"
    ///   "Basia od franka"           → name: "Basia od franka",  service: nil
    private static func parseTitle(_ raw: String) -> (name: String, service: String?) {
        // Regex: \b(\d{1,2}:\d{2})\b  — matches time like "9:15", "10:50", "17:30"
        let timePattern = #"\b\d{1,2}:\d{2}\b"#
        
        guard let regex = try? NSRegularExpression(pattern: timePattern),
              let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
              let timeRange = Range(match.range, in: raw) else {
            // No embedded time found — the whole title is the client name
            return (raw.trimmingCharacters(in: .whitespaces), nil)
        }
        
        // Everything BEFORE the time is the client name
        let namePart = String(raw[raw.startIndex..<timeRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Everything AFTER the time (if any) is the service note
        let afterTime = String(raw[timeRange.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let service: String? = afterTime.isEmpty ? nil : afterTime
        
        // If name is empty (time was at the start), use raw title as name
        let finalName = namePart.isEmpty ? raw : namePart
        
        return (finalName, service)
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate
    }
}