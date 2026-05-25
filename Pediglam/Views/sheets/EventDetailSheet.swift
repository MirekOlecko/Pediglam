import SwiftUI

struct EventDetailSheet: View {
    let event: CalendarEvent
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteError = false
    @State private var deleteErrorMessage = ""
    
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

                        actionButtons
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
            .confirmationDialog("Delete visit?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete Visit", role: .destructive) {
                    deleteVisit()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This removes the appointment from your calendar and from Pediglam.")
            }
            .alert("Could not delete visit", isPresented: $showDeleteError) {
                Button("OK") { }
            } message: {
                Text(deleteErrorMessage)
            }
            .sheet(isPresented: $showEditSheet) {
                CreateVisitSheet(viewModel: viewModel, event: event) {
                    dismiss()
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

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showEditSheet = true
            } label: {
                actionButtonLabel(title: "Edit", icon: "pencil", foreground: .white)
                    .frame(maxWidth: .infinity)
                    .background(AppStyle.accentGradient)
                    .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
                    .shadow(color: Color.iosBlue.opacity(0.22), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            Button {
                showDeleteConfirmation = true
            } label: {
                actionButtonLabel(title: "Delete", icon: "trash", foreground: .busyColor)
                    .frame(maxWidth: .infinity)
                    .background(Color.busyColor.opacity(0.10))
                    .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.controlRadius, style: .continuous)
                            .stroke(Color.busyColor.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func actionButtonLabel(title: String, icon: String, foreground: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))

            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundColor(foreground)
        .padding(.vertical, 14)
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

    private func deleteVisit() {
        if viewModel.deleteVisit(event) {
            dismiss()
        } else {
            deleteErrorMessage = viewModel.error ?? "The calendar event could not be removed."
            showDeleteError = true
        }
    }
}
