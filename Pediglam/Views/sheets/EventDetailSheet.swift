import SwiftUI

struct EventDetailSheet: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        headerCard
                        detailsCard

                        if let notes = event.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            notesCard(notes)
                        }

                        openCalendarButton
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
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

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Text(String(event.clientName.prefix(1).uppercased()))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 58, height: 58)
                    .background(AppStyle.busyGradient)
                    .clipShape(Circle())
                    .shadow(color: Color.busyColor.opacity(0.22), radius: 12, x: 0, y: 7)

                VStack(alignment: .leading, spacing: 7) {
                    Text("CLIENT")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.busyColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.busyColor.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 8, style: .continuous))

                    Text(event.clientName)
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            if let service = event.serviceNote, !service.isEmpty {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))

                    Text(service)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .lineLimit(2)
                }
                .foregroundColor(.busyColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.busyColor.opacity(0.09))
                .clipShape(.rect(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(18)
        .premiumCard(cornerRadius: 26, shadowRadius: 18)
    }

    private var detailsCard: some View {
        PremiumSettingsSection(title: "Details") {
            VStack(spacing: 0) {
                detailRow(icon: "calendar", title: "Date", value: event.startDate.formattedPolishHeader(), color: .iosBlue)
                PremiumRowDivider()
                detailRow(icon: "clock.fill", title: "Time", value: "\(event.startDate.formattedTime()) – \(event.endDate.formattedTime())", color: .premiumGold)
                PremiumRowDivider()
                detailRow(icon: "timer", title: "Duration", value: event.duration.formattedDuration(), color: .freeColor)

                if let location = event.location, !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    PremiumRowDivider()
                    detailRow(icon: "mappin.and.ellipse", title: "Location", value: location, color: .busyColor)
                }
            }
        }
    }

    private func notesCard(_ notes: String) -> some View {
        PremiumSettingsSection(title: "Notes") {
            Text(notes)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
    }

    private var openCalendarButton: some View {
        Button {
            let interval = event.startDate.timeIntervalSinceReferenceDate
            if let url = URL(string: "calshow:\(interval)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .bold))

                Text("Open in Calendar")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(AppStyle.accentGradient)
            .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
            .shadow(color: Color.iosBlue.opacity(0.25), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
    
    private func detailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            SettingsRowIcon(systemName: icon, color: color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondaryText)
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(14)
    }
}
