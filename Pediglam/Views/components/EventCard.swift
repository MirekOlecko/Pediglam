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
            RoundedRectangle(cornerRadius: 1.5)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, 12)
                .padding(.leading, 14)
            
            content
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
        }
        .premiumCard(cornerRadius: 18, shadowRadius: 12)
    }
}
