import SwiftUI

struct BusySlotCard: View {
    let slot: TimeSlot
    let onTap: () -> Void
    
    private var event: CalendarEvent? { slot.associatedEvent }
    
    var body: some View {
        Button(action: onTap) {
            EventCard(accentColor: .busyColor) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        // Time range row
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.busyColor)
                                .font(.system(size: 12))
                            
                            Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondaryText)
                        }
                        
                        // Client name (cleaned, without embedded time)
                        Text(event?.clientName ?? slot.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .lineLimit(2)
                        
                        // Optional service note (e.g. "rece manicure, nogi")
                        if let service = event?.serviceNote, !service.isEmpty {
                            Text(service)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.busyColor.opacity(0.8))
                                .lineLimit(1)
                        }
                        
                        // Duration
                        Text(slot.duration.formattedDuration())
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondaryText.opacity(0.4))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
