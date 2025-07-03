//
//  ItemListDefaultContent.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 03/07/2025.
//

import SwiftUI

struct ItemListDefaultContent: View {
    var deleteItems: (IndexSet) -> Void
    var filteredItems: [Item]
    var filterSelection: String
    var sortSelection: SortOption
    
    var body: some View {
        ForEach(filterAndSortItems()) { item in
            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                Text(item.title)
            }
        }
        .onDelete(perform: deleteItems)
    }
    
    private func filterAndSortItems() -> [Item] {
        var filteredItems = filterSelection == "ALL" ? filteredItems : filteredItems.filter { $0.status.rawValue == filterSelection }
        switch sortSelection {
        case .date: break
        case .name: filteredItems.sort(by: { $0.title < $1.title })
        case .status: filteredItems.sort(by: { $0.status.sortOrder < $1.status.sortOrder })
        }
        return filteredItems
    }
}

#Preview {
    ItemListDefaultContent(deleteItems: { _ in }, filteredItems: [], filterSelection: "ALL", sortSelection: .date)
}
