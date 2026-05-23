import Foundation

enum SlotType: String, Codable {
    case free
    case busy
}

struct TimeSlot: Identifiable, Equatable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    let type: SlotType
    let title: String
    let associatedEvent: CalendarEvent?
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    init(startDate: Date, endDate: Date, type: SlotType, title: String, associatedEvent: CalendarEvent? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.title = title
        self.associatedEvent = associatedEvent
    }
    
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.type == rhs.type &&
        lhs.title == rhs.title &&
        lhs.associatedEvent == rhs.associatedEvent
    }
}
