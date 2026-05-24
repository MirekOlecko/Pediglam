import SwiftUI

struct CreateVisitSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clientName: String = ""
    @State private var selectedDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var serviceNote: String = ""
    
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
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                        .tint(.iosBlue)
                    
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
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
                            Text("\(startTime.formattedTime()) – \(endTime.formattedTime())")
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
                        let cal = Calendar.current
                        let startComp = cal.dateComponents([.hour, .minute], from: startTime)
                        let endComp = cal.dateComponents([.hour, .minute], from: endTime)
                        
                        viewModel.createVisit(
                            clientName: clientName.isEmpty ? "Client" : clientName,
                            date: selectedDate,
                            startHour: startComp.hour ?? 9,
                            startMinute: startComp.minute ?? 0,
                            endHour: endComp.hour ?? 10,
                            endMinute: endComp.minute ?? 0,
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
}
