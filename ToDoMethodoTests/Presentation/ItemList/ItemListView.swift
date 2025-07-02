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
    
    var body: some View {
        NavigationSplitView {
            List {
                if searchText.isEmpty {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            Text(item.title)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                else {
                    Section(header: Text("Résultats pour \"\(searchText)\"")) {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                Text(item.title)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                
                if filteredItems.isEmpty {
                    HStack {
                        Text("No items found")
                    }
                    .frame(maxWidth: .infinity)
                }
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
        .searchable(text: $searchText, prompt: Text("Search a Task"))
        .onAppear { self.filteredItems = searchItems(text: searchText) }
        .onChange(of: searchText) { self.filteredItems = searchItems(text: $1) }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func searchItems(text: String) -> [Item] {
        searchText.isEmpty ? items : items.filter { $0.title.contains(searchText) }
    }
}

#Preview {
    ItemListView()
}
