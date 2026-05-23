import SwiftUI

struct FreeSlotCard: View {
    let slot: TimeSlot
    
    var body: some View {
        EventCard(accentColor: .freeColor) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.badge.checkmark")
                        .foregroundColor(.freeColor)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("FREE")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.freeColor)
                    
                    Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
                
                Text("\(slot.duration.formattedDuration()) free")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
        }
    }
}
