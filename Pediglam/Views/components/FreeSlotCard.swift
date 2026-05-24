import SwiftUI

struct FreeSlotCard: View {
    let slot: TimeSlot
    
    var body: some View {
        EventCard(accentColor: .freeColor) {
            HStack(spacing: 10) {
                // Green dot
                ZStack {
                    Circle()
                        .fill(Color.freeColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.freeColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(slot.startDate.formattedTime()) – \(slot.endDate.formattedTime())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryText)
                    
                    Text("\(slot.duration.formattedDuration()) free")
                        .font(.system(size: 12))
                        .foregroundColor(.freeColor)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
