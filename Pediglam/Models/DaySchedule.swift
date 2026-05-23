import Foundation

struct DaySchedule {
    let date: Date
    let slots: [TimeSlot]
    
    var totalFreeTime: TimeInterval {
        slots.filter { $0.type == .free }.reduce(0) { $0 + $1.duration }
    }
    
    var totalBusyTime: TimeInterval {
        slots.filter { $0.type == .busy }.reduce(0) { $0 + $1.duration }
    }
    
    var totalWorkTime: TimeInterval {
        totalFreeTime + totalBusyTime
    }
    
    var occupancyRate: Double {
        let total = totalWorkTime
        guard total > 0 else { return 0.0 }
        return totalBusyTime / total
    }
}
