//
//  ItemDetailView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 01/07/2025.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        Form {
            Section("Title") {
                TextField("Type a title...", text: Binding(get: { item.title }, set: { item.title = $0 }))
            }
            
            Section("Description") {
                TextField("Description is empty", text: Binding(get: { item.itemDescription }, set: { item.itemDescription = $0 }))
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
                                .foregroundStyle(computeColor(item.status))
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
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func computeColor(_ status: TaskStatus) -> Color {
        switch status {
            case .done:
                    .green
            case .inProgress:
                    .orange
            case .todo:
                    .blue
        }
    }
}

#Preview {
    ItemDetailView(item: Item(id: UUID(), title: "", itemDescription: "", timestamp: Date(), dueDate: .now, status: .done))
}
