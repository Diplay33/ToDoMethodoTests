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
    @State private var showingUsersView = false
    @State var searchText: String = ""
    @State var filterSelection: String = "ALL"
    @State var sortSelection: SortOption = .date
    
    var body: some View {
        NavigationSplitView {
            List {
                if searchText.isEmpty {
                    ItemListDefaultContent(deleteItems: deleteItems, filteredItems: filteredItems, filterSelection: filterSelection, sortSelection: sortSelection)
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
                        Picker("", selection: $sortSelection) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue.capitalized)
                            }
                        }
                    }
                    label: {
                        Label("", systemImage: "arrow.up.arrow.down")
                    }
                }
                
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
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingUsersView = true }) {
                        Label("Show User", systemImage: "person.crop.circle")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $showingAddItemView) {
            AddItemView()
        }
        .sheet(isPresented: $showingUsersView) {
            UsersView()
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

enum SortOption: String, CaseIterable {
    case date, name, status
}

#Preview {
    ItemListView()
}
