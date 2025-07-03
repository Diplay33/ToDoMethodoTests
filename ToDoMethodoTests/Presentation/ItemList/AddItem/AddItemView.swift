//
//  AddItemView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 01/07/2025.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    // MARK: - Private Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var itemDescription: String = ""

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
            let newItem = Item(id: UUID(), title: title.trimmingCharacters(in: .whitespacesAndNewlines), itemDescription: itemDescription, timestamp: Date(), dueDate: Date().addingTimeInterval(86400*7), status: .todo, priority: .normal)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    AddItemView()
}
