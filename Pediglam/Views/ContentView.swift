import SwiftUI
import EventKit

struct ContentView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedEventDetail: CalendarEvent? = nil
    @State private var showCreateVisit = false
    
    var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header component
                HeaderView(viewModel: viewModel)
                
                // Sub-header (Date picker & Work hours display)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedDate.formattedPolishHeader())
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        
                        let startStr = String(format: "%d:%02d", viewModel.workStartHour, viewModel.workStartMinute)
                        let endStr = String(format: "%d:%02d", viewModel.workEndHour, viewModel.workEndMinute)
                        Text("Working hours: \(startStr) – \(endStr)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Add visit button
                    Button(action: { showCreateVisit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.iosBlue)
                    }
                    
                    DatePicker(
                        "",
                        selection: $viewModel.selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.iosBlue)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                Divider()
                    .background(Color.separator)
                
                // Main content body
                if viewModel.isLoading && viewModel.slots.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(.iosBlue)
                    Spacer()
                } else if viewModel.slots.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.slots) { slot in
                                if slot.type == .free {
                                    FreeSlotCard(slot: slot)
                                } else {
                                    BusySlotCard(slot: slot) {
                                        if let event = slot.associatedEvent {
                                            selectedEventDetail = event
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        viewModel.loadEvents()
                    }
                    
                    Divider()
                        .background(Color.separator)
                    
                    SummaryView(schedule: viewModel.daySchedule)
                        .padding(.vertical, 12)
                        .background(Color.systemBackground)
                }
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .sheet(item: $selectedEventDetail) { event in
            EventDetailSheet(event: event)
        }
        .sheet(isPresented: $showCreateVisit) {
            CreateVisitSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }
}
