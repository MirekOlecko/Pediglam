import SwiftUI

struct SummaryView: View {
    let schedule: DaySchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.iosBlue)
                    .font(.system(size: 16))
                
                Text("Day Summary")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
            }
            
            // Custom visual progress gauge split
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
                .cornerRadius(6)
            }
            .frame(height: 8)
            .padding(.vertical, 2)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FREE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    
                    Text(schedule.totalFreeTime.formattedDuration())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.freeColor)
                }
                
                Spacer()
                
                // Show utilization percentage in the middle
                if schedule.totalWorkTime > 0 {
                    VStack(alignment: .center, spacing: 4) {
                        Text("OCCUPANCY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondaryText)
                        
                        Text(String(format: "%.0f%%", schedule.occupancyRate * 100))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("BUSY")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    
                    Text(schedule.totalBusyTime.formattedDuration())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.busyColor)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}
