import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppStyle.freeGradient)
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.freeColor.opacity(0.24), radius: 18, x: 0, y: 10)
                
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("You're completely free today!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text("No appointments scheduled during working hours.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("Add in Calendar")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppStyle.accentGradient)
                .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
                .shadow(color: Color.iosBlue.opacity(0.25), radius: 12, x: 0, y: 7)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
}
