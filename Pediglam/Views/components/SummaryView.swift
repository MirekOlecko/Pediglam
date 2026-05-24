import SwiftUI

struct SummaryView: View {
    let schedule: DaySchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppStyle.accentGradient)
                        .frame(width: 38, height: 38)

                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Day Summary")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text("Free vs booked time")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                Text(String(format: "%.0f%%", schedule.occupancyRate * 100))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            
            GeometryReader { geo in
                HStack(spacing: 0) {
                    let total = schedule.totalWorkTime
                    if total > 0 {
                        let busyWidth = geo.size.width * CGFloat(schedule.totalBusyTime / total)
                        
                        if busyWidth > 0 {
                            Rectangle()
                                .fill(Color.busyColor)
                                .frame(width: busyWidth)
                        }
                        
                        if geo.size.width - busyWidth > 0 {
                            Rectangle()
                                .fill(Color.freeColor)
                                .frame(width: geo.size.width - busyWidth)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.secondaryText.opacity(0.15))
                            .frame(width: geo.size.width)
                    }
                }
                .clipShape(.rect(cornerRadius: 6, style: .continuous))
            }
            .frame(height: 10)
            .padding(.vertical, 2)
            
            HStack {
                SummaryMetric(title: "Free", value: schedule.totalFreeTime.formattedDuration(), color: .freeColor)
                Spacer()
                SummaryMetric(title: "Busy", value: schedule.totalBusyTime.formattedDuration(), color: .busyColor, alignment: .trailing)
            }
        }
        .padding(18)
        .premiumCard(cornerRadius: 24, shadowRadius: 18)
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String
    let color: Color
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondaryText)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}
