//
//  ItemDetailView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 01/07/2025.
//

import SwiftUI

struct ItemDetailView: View {
    @State var showDatePicker: Bool = false
    
    let item: Item

    var body: some View {
        Form {
            Section("Title") {
                TextField("Type a title...", text: Binding(get: { item.title }, set: { item.title = $0 }))
            }
            
            Section("Description") {
                TextField("Description is empty", text: Binding(get: { item.itemDescription }, set: { item.itemDescription = $0 }))
            }
            
            Section("Due Date") {
                HStack {
                    if let dueDate = item.dueDate {
                        Text(dueDate, format: Date.FormatStyle(date: .long, time: .standard))
                    }
                    else {
                        Text("No due date set")
                    }
                    
                    Spacer()
                    
                    Button(action: { withAnimation { showDatePicker.toggle() } }) {
                        Text(showDatePicker ? "Done" : "Edit")
                    }
                }
                
                if showDatePicker {
                    DatePicker("", selection: Binding(get: { item.dueDate ?? .now }, set: { item.dueDate = $0 }))
                        .datePickerStyle(.graphical)                    
                }
            }
            
            Section("Created Date") {
                Text(item.timestamp, format: Date.FormatStyle(date: .long, time: .standard))
            }
            
            Section("Status") {
                Menu {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Toggle(status.rawValue, isOn: Binding(get: { item.status == status }, set: { _ in item.status = status }))
                    }
                }
                label: {
                    HStack {
                        HStack {
                            Circle()
                                .foregroundStyle(computeStatusColor(item.status))
                                .frame(height: 16)
                            
                            Text(item.status.rawValue)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
            
            Section("Priority Level") {
                Menu {
                    ForEach(TaskPriority.allCases, id: \.self) { level in
                        Toggle(level.rawValue, isOn: Binding(get: { item.priority == level } , set: { _ in item.priority = level }))
                    }
                }
                label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .foregroundStyle(computePriorityColor(item.priority))
                                .frame(height: 16)
                            
                            Text(item.priority.rawValue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func computeStatusColor(_ status: TaskStatus) -> Color {
        switch status {
            case .done: .green
            case .inProgress: .orange
            case .todo: .blue
        }
    }
    
    private func computePriorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .critical: .red
        case .high: .orange
        case .normal: .yellow
        case .low: .gray
        }
    }
}

#Preview {
    ItemDetailView(item: Item(id: UUID(), title: "", itemDescription: "", timestamp: Date(), dueDate: .now, status: .done, priority: .critical))
}
