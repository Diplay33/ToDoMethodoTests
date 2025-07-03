//
//  ItemListView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 01/07/2025.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @State var filteredItems: [Item] = []
    @State private var showingAddItemView = false
    @State var searchText: String = ""
    @State var filterSelection: String = "ALL"
    
    var body: some View {
        NavigationSplitView {
            List {
                if searchText.isEmpty {
                    ItemListDefaultContent(deleteItems: deleteItems, filteredItems: filteredItems, filterSelection: filterSelection)
                }
                else {
                    ItemListSearchResults(searchText: searchText, filteredItems: filteredItems, deleteItems: deleteItems)
                }
                
                if filteredItems.isEmpty {
                    HStack {
                        Text(searchText.isEmpty ? "No items" : "No items found")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("ToDo Items")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("", selection: $filterSelection) {
                            ForEach(["ALL"] + TaskStatus.allCases.map(\.rawValue), id: \.self) { status in
                                Text(status)
                            }
                        }
                    }
                    label: {
                        Label("", systemImage: "line.3.horizontal.decrease")
                    }
                }
                
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
        .searchable(text: $searchText, prompt: Text("Search a Task"))
        .onAppear { self.filteredItems = searchItems() }
        .onChange(of: searchText) { self.filteredItems = searchItems() }
        .onChange(of: items) { self.filteredItems = searchItems() }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func searchItems() -> [Item] {
        searchText.isEmpty ? items : items.filter { $0.title.contains(searchText) }
    }
}

#Preview {
    ItemListView()
}
