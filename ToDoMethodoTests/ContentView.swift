//
//  ContentView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Private Properties

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @State private var showingAddItemView = false

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        Text(item.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("ToDo Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddItemView = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $showingAddItemView) {
            AddItemView()
        }
    }

    // MARK: - Private Methods

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Helpers

private struct ItemDetailView: View {
    // MARK: - Exposed Properties

    let item: Item

    // MARK: - Body

    var body: some View {
        Form {
            Section("Title") {
                Text(item.title)
            }
            Section("Description") {
                Text(item.itemDescription.isEmpty ? "No description" : item.itemDescription)
            }
            Section("Created Date") {
                Text(item.timestamp, format: Date.FormatStyle(date: .long, time: .standard))
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AddItemView: View {
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
            let newItem = Item(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                itemDescription: itemDescription,
                timestamp: Date()
            )
            modelContext.insert(newItem)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
