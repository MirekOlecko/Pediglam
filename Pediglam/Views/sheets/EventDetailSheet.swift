import SwiftUI

struct EventDetailSheet: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KLIENT")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.busyColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.busyColor.opacity(0.12))
                            .cornerRadius(6)
                        
                        // Client name (cleaned — without embedded time)
                        Text(event.clientName)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Service description if present (e.g. "rece manicure, nogi")
                        if let service = event.serviceNote, !service.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "scissors")
                                    .font(.system(size: 12))
                                    .foregroundColor(.busyColor.opacity(0.7))
                                Text(service)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.busyColor.opacity(0.85))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.busyColor.opacity(0.08))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Detail Blocks
                    VStack(spacing: 1) {
                        detailRow(icon: "calendar", title: "Date", value: event.startDate.formattedPolishHeader())
                        detailRow(icon: "clock", title: "Time", value: "\(event.startDate.formattedTime()) – \(event.endDate.formattedTime())")
                        detailRow(icon: "timer", title: "Duration", value: event.duration.formattedDuration())
                        
                        if let location = event.location, !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            detailRow(icon: "mappin.and.ellipse", title: "Location", value: location)
                        }
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Notes Section
                    if let notes = event.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.secondaryText)
                                .padding(.horizontal)
                            
                            Text(notes)
                                .font(.system(size: 15))
                                .foregroundColor(.primaryText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cardBackground)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Open in Calendar Button
                    Button(action: {
                        let interval = event.startDate.timeIntervalSinceReferenceDate
                        if let url = URL(string: "calshow:\(interval)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Open in Calendar")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.iosBlue)
                        .cornerRadius(14)
                        .shadow(color: Color.iosBlue.opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.systemBackground)
            .navigationTitle("Appointment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.secondaryText)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.secondaryText)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondaryText)
                
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
