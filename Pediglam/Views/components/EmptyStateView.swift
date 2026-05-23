import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.freeColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.freeColor)
                    .shadow(color: Color.freeColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            VStack(spacing: 8) {
                Text("You're completely free today!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text("No appointments scheduled during working hours.")
                    .font(.system(size: 14))
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
                .background(Color.iosBlue)
                .cornerRadius(12)
                .shadow(color: Color.iosBlue.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.vertical)
    }
}
