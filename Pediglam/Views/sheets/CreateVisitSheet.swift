import SwiftUI

struct CreateVisitSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    private let editingEvent: CalendarEvent?
    private let onSaved: (() -> Void)?
    
    @State private var clientName: String = ""
    @State private var selectedDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var serviceNote: String = ""
    @State private var showConflictAlert = false
    @State private var conflictMessage = ""
    @FocusState private var focusedField: FocusedField?

    private enum FocusedField: Hashable {
        case clientName
        case serviceNote
    }
    
    init(viewModel: CalendarViewModel, onSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.editingEvent = nil
        self.onSaved = onSaved
        _selectedDate = State(initialValue: viewModel.selectedDate)
        
        let calendar = Calendar.current
        let today = Date()
        let start = calendar.date(bySettingHour: viewModel.workStartHour, minute: 0, second: 0, of: today) ?? today
        let end = calendar.date(bySettingHour: viewModel.workStartHour + 1, minute: 0, second: 0, of: today) ?? today
        _startTime = State(initialValue: start)
        _endTime = State(initialValue: end)
    }

    init(viewModel: CalendarViewModel, event: CalendarEvent, onSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.editingEvent = event
        self.onSaved = onSaved
        _clientName = State(initialValue: event.clientName == "Busy" ? "" : event.clientName)
        _selectedDate = State(initialValue: event.startDate)
        _startTime = State(initialValue: event.startDate)
        _endTime = State(initialValue: event.endDate)
        _serviceNote = State(initialValue: event.serviceNote ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        clientSection
                        dateSection
                        timeSection
                        previewSection
                    }
                    .padding(.horizontal, AppStyle.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Visit" : "New Visit")
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

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Save Visit") {
                        saveVisit()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.iosBlue)
                    .disabled(!canSave)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    if focusedField == .clientName {
                        Button("Next") {
                            focusedField = .serviceNote
                        }
                        .fontWeight(.semibold)
                    }

                    Spacer()

                    Button("Done") {
                        dismissKeyboard()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var clientSection: some View {
        PremiumSettingsSection(title: "Client") {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "person.fill", color: .iosBlue)

                    TextField("Client name", text: $clientName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .focused($focusedField, equals: .clientName)
                        .submitLabel(.next)
                        .textInputAutocapitalization(.words)
                        .onSubmit {
                            focusedField = .serviceNote
                        }
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "sparkles", color: .premiumGold)

                    TextField("Service note (optional)", text: $serviceNote)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.primaryText)
                        .focused($focusedField, equals: .serviceNote)
                        .submitLabel(.done)
                        .onSubmit {
                            dismissKeyboard()
                        }
                }
                .padding(14)
            }
        }
    }

    private var dateSection: some View {
        PremiumSettingsSection(title: "Date") {
            DatePicker("Date", selection: selectedDateBinding, displayedComponents: [.date])
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

                    DatePicker("Start", selection: startTimeBinding, displayedComponents: .hourAndMinute)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .tint(.iosBlue)
                }
                .padding(14)

                PremiumRowDivider()

                HStack(spacing: 12) {
                    SettingsRowIcon(systemName: "timer", color: .busyColor)

                    DatePicker("End", selection: endTimeBinding, displayedComponents: .hourAndMinute)
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

    private var canSave: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isEditing: Bool {
        editingEvent != nil
    }

    private var selectedDateBinding: Binding<Date> {
        Binding(
            get: { selectedDate },
            set: { newValue in
                dismissKeyboard()
                selectedDate = newValue
            }
        )
    }

    private var startTimeBinding: Binding<Date> {
        Binding(
            get: { startTime },
            set: { newValue in
                dismissKeyboard()
                startTime = newValue
            }
        )
    }

    private var endTimeBinding: Binding<Date> {
        Binding(
            get: { endTime },
            set: { newValue in
                dismissKeyboard()
                endTime = newValue
            }
        )
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

        let trimmedClientName = clientName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedServiceNote = serviceNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let serviceNoteValue = trimmedServiceNote.isEmpty ? nil : trimmedServiceNote

        let success: Bool
        if let editingEvent {
            success = viewModel.updateVisit(
                editingEvent,
                clientName: trimmedClientName,
                date: selectedDate,
                startHour: startComp.hour ?? 9,
                startMinute: startComp.minute ?? 0,
                endHour: endComp.hour ?? 10,
                endMinute: endComp.minute ?? 0,
                serviceNote: serviceNoteValue
            )
        } else {
            success = viewModel.createVisit(
                clientName: trimmedClientName,
                date: selectedDate,
                startHour: startComp.hour ?? 9,
                startMinute: startComp.minute ?? 0,
                endHour: endComp.hour ?? 10,
                endMinute: endComp.minute ?? 0,
                serviceNote: serviceNoteValue
            )
        }

        if success {
            onSaved?()
            dismiss()
        } else if let error = viewModel.error {
            conflictMessage = error
            showConflictAlert = true
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}
