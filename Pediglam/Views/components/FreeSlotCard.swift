import SwiftUI

struct FreeSlotCard: View {
    let slot: TimeSlot
    
    var body: some View {
        EventCard(accentColor: .freeColor) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppStyle.freeGradient)
                        .frame(width: 38, height: 38)
                        .shadow(color: Color.freeColor.opacity(0.22), radius: 8, x: 0, y: 5)
                    
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()

                Text(slot.duration.formattedDuration())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.freeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.freeColor.opacity(0.10))
                    .clipShape(.capsule)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
