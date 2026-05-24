import SwiftUI

struct EventCard<Content: View>: View {
    let content: Content
    let accentColor: Color
    
    init(accentColor: Color, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Thin accent bar — 3px like iOS Calendar
            RoundedRectangle(cornerRadius: 1.5)
                .fill(accentColor)
                .frame(width: 3)
                .padding(.vertical, 6)
                .padding(.leading, 12)
            
            content
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .background(Color.cardBackground)
        .cornerRadius(10)
    }
}
