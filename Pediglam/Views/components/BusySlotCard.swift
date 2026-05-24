import SwiftUI

struct BusySlotCard: View {
    let slot: TimeSlot
    let onTap: () -> Void
    
    private var event: CalendarEvent? { slot.associatedEvent }

    var body: some View {
        Button(action: onTap) {
            EventCard(accentColor: .busyColor) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppStyle.busyGradient)
                            .frame(width: 38, height: 38)
                            .shadow(color: Color.busyColor.opacity(0.22), radius: 8, x: 0, y: 5)

                        Text(String(slot.title.prefix(1).uppercased()))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(slot.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
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
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        Text(slot.duration.formattedDuration())
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondaryText)
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
