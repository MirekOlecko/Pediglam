import SwiftUI

struct CreateVisitSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clientName: String = ""
    @State private var selectedDate: Date
    @State private var startHour: Int = 9
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 10
    @State private var endMinute: Int = 0
    @State private var serviceNote: String = ""
    
    private let hours = Array(6...22)
    private let minutes = Array(stride(from: 0, through: 55, by: 5))
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        _selectedDate = State(initialValue: viewModel.selectedDate)
        _startHour = State(initialValue: viewModel.workStartHour)
        _endHour = State(initialValue: viewModel.workStartHour + 1)
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
                    timePickerRow(label: "Start", hour: $startHour, minute: $startMinute)
                    timePickerRow(label: "End", hour: $endHour, minute: $endMinute)
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
                            Text("\(startTimeString) – \(endTimeString)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primaryText)
                            
                            Text(durationString)
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
                            startHour: startHour,
                            startMinute: startMinute,
                            endHour: endHour,
                            endMinute: endMinute,
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
    
    // MARK: - Time Picker Row
    private func timePickerRow(label: String, hour: Binding<Int>, minute: Binding<Int>) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondaryText)
                .frame(width: 50, alignment: .leading)
            
            Spacer()
            
            Picker("Hour", selection: hour) {
                ForEach(hours, id: \.self) { h in
                    Text(String(format: "%02d", h))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 110)
            
            Text(":")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primaryText)
                .frame(width: 16)
            
            Picker("Minute", selection: minute) {
                ForEach(minutes, id: \.self) { m in
                    Text(String(format: "%02d", m))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 110)
        }
        .padding(.vertical, 4)
    }
    
    private var startTimeString: String {
        String(format: "%d:%02d", startHour, startMinute)
    }
    
    private var endTimeString: String {
        String(format: "%d:%02d", endHour, endMinute)
    }
    
    private var durationString: String {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let diff = max(0, endMinutes - startMinutes)
        
        if diff < 60 {
            return "\(diff) min"
        } else {
            let h = diff / 60
            let m = diff % 60
            return m == 0 ? "\(h)h" : "\(h)h \(m)min"
        }
    }
}
