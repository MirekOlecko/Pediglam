import SwiftUI

struct BusySlotCard: View {
    let slot: TimeSlot
    let onTap: () -> Void
    
    private var event: CalendarEvent? { slot.associatedEvent }
    
    var body: some View {
        Button(action: onTap) {
            EventCard(accentColor: .busyColor) {
                HStack(spacing: 10) {
                    // Colored dot with initial — like iOS Calendar
                    ZStack {
                        Circle()
                            .fill(Color.busyColor.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Text(String((event?.clientName ?? "?").prefix(1).uppercased()))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.busyColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event?.clientName ?? slot.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        
                        if let service = event?.serviceNote, !service.isEmpty {
                            Text(service)
                                .font(.system(size: 12))
                                .foregroundColor(.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondaryText)
                        
                        Text(slot.duration.formattedDuration())
                            .font(.system(size: 11))
                            .foregroundColor(.secondaryText.opacity(0.7))
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondaryText.opacity(0.3))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
