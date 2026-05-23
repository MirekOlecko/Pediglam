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
                    // Start
                    HStack {
                        Text("Start")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        
                        Picker("Hour", selection: $startHour) {
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
                        
                        Picker("Minute", selection: $startMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()
                    }
                    
                    // End
                    HStack {
                        Text("End")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        
                        Picker("Hour", selection: $endHour) {
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
                        
                        Picker("Minute", selection: $endMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()
                    }
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
