import Foundation

extension Date {
    func formattedPolishHeader() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        // "EEEE, d MMMM yyyy" -> e.g. "Sunday, 24 May 2026"
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        let rawDate = formatter.string(from: self)
        // Capitalize the first letter (e.g. "Sunday, 24 May 2026")
        return rawDate.prefix(1).uppercased() + rawDate.dropFirst()
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    func formattedDuration() -> String {
        let totalMinutes = Int((self / 60).rounded())
        guard totalMinutes > 0 else { return "0 min" }
        
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)min"
            }
        }
    }
    
    func formattedDurationPolish() -> String {
        let totalMinutes = Int((self / 60).rounded())
        guard totalMinutes > 0 else { return "0 minut" }
        
        if totalMinutes < 60 {
            return "\(totalMinutes) \(minutesSuffix(totalMinutes))"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            if minutes == 0 {
                return "\(hours) \(hoursSuffix(hours))"
            } else {
                return "\(hours) \(hoursSuffix(hours)) \(minutes) \(minutesSuffix(minutes))"
            }
        }
    }
    
    private func hoursSuffix(_ count: Int) -> String {
        if count == 1 { return "godzina" }
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        if lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 10 || lastTwoDigits > 20) {
            return "godziny"
        }
        return "godzin"
    }
    
    private func minutesSuffix(_ count: Int) -> String {
        if count == 1 { return "minuta" }
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        if lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 10 || lastTwoDigits > 20) {
            return "minuty"
        }
        return "minut"
    }
}
