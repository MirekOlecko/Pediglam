import SwiftUI
import UIKit

struct FreeSlotCard: View {
    let slot: TimeSlot
    @State private var showCopiedAlert = false
    
    var body: some View {
        EventCard(accentColor: .freeColor) {
            HStack {
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
                
                Spacer()
                
                if showCopiedAlert {
                    Text("Copied!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.freeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.freeColor.opacity(0.15))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image(systemName: "square.on.square")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText.opacity(0.6))
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            copyToClipboard()
        }
    }
    
    private func copyToClipboard() {
        let copyText = "Free: \(slot.startDate.formattedTime())–\(slot.endDate.formattedTime()) (\(slot.duration.formattedDuration()))"
        UIPasteboard.general.string = copyText
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.spring()) {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }
}
