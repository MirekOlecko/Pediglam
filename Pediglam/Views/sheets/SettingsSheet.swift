import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var startPickerDate = Date()
    @State private var endPickerDate = Date()
    @State private var filterNoTitle = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("WORKING HOURS")) {
                    DatePicker("Start time", selection: $startPickerDate, displayedComponents: .hourAndMinute)
                        .tint(.iosBlue)
                    
                    DatePicker("End time", selection: $endPickerDate, displayedComponents: .hourAndMinute)
                        .tint(.iosBlue)
                }
                
                Section(header: Text("FILTERS")) {
                    Toggle("Show clients only", isOn: $filterNoTitle)
                        .tint(.iosBlue)
                    
                    Text("Hide calendar events that don't have a title/client entered.")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Pediglam")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Text("Copyright")
                        Spacer()
                        Text("© 2026 Pediglam")
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .background(Color.systemBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.iosBlue)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }
    
    private func loadCurrentSettings() {
        let calendar = Calendar.current
        let today = Date()
        
        startPickerDate = calendar.date(bySettingHour: viewModel.workStartHour, minute: viewModel.workStartMinute, second: 0, of: today) ?? today
        endPickerDate = calendar.date(bySettingHour: viewModel.workEndHour, minute: viewModel.workEndMinute, second: 0, of: today) ?? today
        filterNoTitle = viewModel.filterNoTitleEvents
    }
    
    private func saveSettings() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startPickerDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endPickerDate)
        
        viewModel.workStartHour = startComponents.hour ?? 9
        viewModel.workStartMinute = startComponents.minute ?? 0
        viewModel.workEndHour = endComponents.hour ?? 19
        viewModel.workEndMinute = endComponents.minute ?? 0
        viewModel.filterNoTitleEvents = filterNoTitle
    }
}
