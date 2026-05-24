import Foundation

enum SlotType: String, Codable {
    case free
    case busy
}

struct TimeSlot: Identifiable, Equatable {
    let startDate: Date
    let endDate: Date
    let type: SlotType
    let title: String
    let associatedEvents: [CalendarEvent]

    // Stable ID derived from content — avoids ForEach churn on every recalculation
    var id: String {
        "\(type.rawValue)|\(Int(startDate.timeIntervalSinceReferenceDate))|\(Int(endDate.timeIntervalSinceReferenceDate))"
    }

    // Convenience accessor — returns first event (primary or merged)
    var associatedEvent: CalendarEvent? { associatedEvents.first }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    // Single-event init (backward-compatible)
    init(startDate: Date, endDate: Date, type: SlotType, title: String, associatedEvent: CalendarEvent? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.title = title
        self.associatedEvents = associatedEvent.map { [$0] } ?? []
    }

    // Multi-event init for merged overlapping slots
    init(startDate: Date, endDate: Date, type: SlotType, title: String, associatedEvents: [CalendarEvent]) {
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.title = title
        self.associatedEvents = associatedEvents
    }

    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.type == rhs.type &&
        lhs.title == rhs.title &&
        lhs.associatedEvents == rhs.associatedEvents
    }
}
