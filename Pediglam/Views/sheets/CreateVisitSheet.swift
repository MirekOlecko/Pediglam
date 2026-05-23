import SwiftUI

struct CreateVisitSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clientName: String = ""
    @State private var selectedDate: Date
    @State private var selectedHour: Int = 9
    @State private var selectedMinute: Int = 0
    @State private var selectedDuration: Int = 60
    @State private var serviceNote: String = ""
    
    private let durations = [15, 30, 45, 60, 75, 90, 105, 120]
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        _selectedDate = State(initialValue: viewModel.selectedDate)
        _selectedHour = State(initialValue: viewModel.workStartHour)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Client info
                Section("Client") {
                    TextField("Client name", text: $clientName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    TextField("Service note (optional)", text: $serviceNote)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                }
                
                // Date
                Section("Date") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(.iosBlue)
                }
                
                // Time
                Section("Time") {
                    HStack {
                        Text("Start")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(6...22, id: \.self) { h in
                                Text(String(format: "%02d", h)).tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()
                        
                        Text(":")
                            .font(.title2)
                            .foregroundColor(.primaryText)
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()
                    }
                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(durations, id: \.self) { d in
                            Text(durationLabel(d)).tag(d)
                        }
                    }
                    .tint(.iosBlue)
                }
                
                // Preview
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clientName.isEmpty ? "Client name" : clientName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(clientName.isEmpty ? .secondaryText : .primaryText)
                            
                            if !serviceNote.isEmpty {
                                Text(serviceNote)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(timeString)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primaryText)
                            
                            Text(durationLabel(selectedDuration))
                                .font(.system(size: 12))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createVisit(
                            clientName: clientName.isEmpty ? "Client" : clientName,
                            date: selectedDate,
                            hour: selectedHour,
                            minute: selectedMinute,
                            durationMinutes: selectedDuration,
                            serviceNote: serviceNote.isEmpty ? nil : serviceNote
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(clientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private var timeString: String {
        String(format: "%d:%02d", selectedHour, selectedMinute)
    }
    
    private func durationLabel(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "\(h)h" : "\(h)h \(m)min"
        }
    }
}
