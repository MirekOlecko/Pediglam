import SwiftUI

struct CreateVisitSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clientName: String = ""
    @State private var selectedDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var serviceNote: String = ""
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        _selectedDate = State(initialValue: viewModel.selectedDate)
        
        let calendar = Calendar.current
        let today = Date()
        let start = calendar.date(bySettingHour: viewModel.workStartHour, minute: 0, second: 0, of: today) ?? today
        let end = calendar.date(bySettingHour: viewModel.workStartHour + 1, minute: 0, second: 0, of: today) ?? today
        _startTime = State(initialValue: start)
        _endTime = State(initialValue: end)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        sheetIntro
                        clientSection
                        dateSection
                        timeSection
                        previewSection
                        saveButton
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("New Visit")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Time Conflict", isPresented: $showConflictAlert) {
                Button("OK") { }
            } message: {
                Text(conflictMessage)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondaryText)
                }
            }
        }
    }

    private var sheetIntro: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppStyle.busyGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.busyColor.opacity(0.22), radius: 12, x: 0, y: 7)

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Book a visit")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Text("Create a clean calendar appointment")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondaryText)
            }

            Spacer()
        }
        .padding(18)
        .premiumCard(cornerRadius: 24, shadowRadius: 16)
    }

    private var clientSection: some View {
        PremiumSettingsSection(title: "Client") {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "person.fill", color: .iosBlue)

                    TextField("Client name", text: $clientName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .textInputAutocapitalization(.words)
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "sparkles", color: .premiumGold)

                    TextField("Service note (optional)", text: $serviceNote)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.primaryText)
                }
                .padding(14)
            }
        }
    }

    private var dateSection: some View {
        PremiumSettingsSection(title: "Date") {
            DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(.iosBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
    }

    private var timeSection: some View {
        PremiumSettingsSection(title: "Time") {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "clock.fill", color: .freeColor)

                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "timer", color: .busyColor)

                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)
            }
        }
    }

    private var previewSection: some View {
        PremiumSettingsSection(title: "Preview", trailing: durationString) {
            HStack(spacing: 12) {
                Text(String((clientName.isEmpty ? "C" : clientName).prefix(1)).uppercased())
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(AppStyle.busyGradient)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(clientName.isEmpty ? "Client name" : clientName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(clientName.isEmpty ? .secondaryText : .primaryText)
                        .lineLimit(1)

                    Text(serviceNote.isEmpty ? "No service note" : serviceNote)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(startTime.formattedTime()) – \(endTime.formattedTime())")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text(selectedDate.formattedShortDate())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(14)
        }
    }

    private var saveButton: some View {
        Button {
            saveVisit()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))

                Text("Save visit")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(canSave ? AnyShapeStyle(AppStyle.accentGradient) : AnyShapeStyle(Color.secondaryText.opacity(0.24)))
            .clipShape(.rect(cornerRadius: AppStyle.controlRadius, style: .continuous))
            .shadow(color: canSave ? Color.iosBlue.opacity(0.25) : .clear, radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.top, 4)
    }

    private var canSave: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var durationString: String {
        let startComp = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let endComp = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        let startMinutes = (startComp.hour ?? 0) * 60 + (startComp.minute ?? 0)
        let endMinutes = (endComp.hour ?? 0) * 60 + (endComp.minute ?? 0)
        let diff = max(0, endMinutes - startMinutes)
        
        if diff < 60 {
            return "\(diff) min"
        } else {
            let h = diff / 60
            let m = diff % 60
            return m == 0 ? "\(h)h" : "\(h)h \(m)min"
        }
    }

    private func saveVisit() {
        guard canSave else { return }

        let cal = Calendar.current
        let startComp = cal.dateComponents([.hour, .minute], from: startTime)
        let endComp = cal.dateComponents([.hour, .minute], from: endTime)

        let success = viewModel.createVisit(
            clientName: clientName.trimmingCharacters(in: .whitespacesAndNewlines),
            date: selectedDate,
            startHour: startComp.hour ?? 9,
            startMinute: startComp.minute ?? 0,
            endHour: endComp.hour ?? 10,
            endMinute: endComp.minute ?? 0,
            serviceNote: serviceNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : serviceNote.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        if success {
            dismiss()
        } else if let error = viewModel.error {
            conflictMessage = error
            showConflictAlert = true
        }
    }
}
