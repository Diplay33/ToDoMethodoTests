//
//  AddItemView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 01/07/2025.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var itemDescription: String = ""
    @State private var dueDate: Date?
    @State var showDatePicker: Bool = false

    private var isFormValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty && trimmedTitle.count < 100 && itemDescription.count < 500
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Title (required)") {
                    TextField("What to do?", text: $title)
                }

                Section("Description (optional)") {
                    TextEditor(text: $itemDescription)
                        .frame(minHeight: 150)
                }
                
                Section("Due Date") {
                    HStack {
                        if let dueDate {
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
                        DatePicker("", selection: Binding(get: { dueDate ?? .now }, set: { dueDate = $0 }))
                            .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addItem()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func addItem() {
        withAnimation {
            let newItem = Item(id: UUID(), title: title.trimmingCharacters(in: .whitespacesAndNewlines), itemDescription: itemDescription, timestamp: Date(), dueDate: dueDate, status: .todo, priority: .normal)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    AddItemView()
}
