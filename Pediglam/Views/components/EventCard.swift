import SwiftUI

struct EventCard<Content: View>: View {
    let content: Content
    let accentColor: Color
    
    @State private var isTapped = false
    
    init(accentColor: Color, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Accent bar on the left
            Rectangle()
                .fill(accentColor)
                .frame(width: 5)
                .cornerRadius(2.5)
                .padding(.vertical, 8)
                .padding(.leading, 8)
            
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        .scaleEffect(isTapped ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isTapped)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isTapped = pressing
        }, perform: {})
    }
}
