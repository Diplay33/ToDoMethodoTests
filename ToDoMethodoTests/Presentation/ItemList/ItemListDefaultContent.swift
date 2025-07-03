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
    
    var body: some View {
        ForEach(filterItemsByFilterSelection()) { item in
            NavigationLink {
                ItemDetailView(item: item)
            } label: {
                Text(item.title)
            }
        }
        .onDelete(perform: deleteItems)
    }
    
    private func filterItemsByFilterSelection() -> [Item] {
        guard filterSelection != "ALL" else { return filteredItems }
        return filteredItems.filter { $0.status.rawValue == filterSelection }
    }
}

#Preview {
    ItemListDefaultContent(deleteItems: { _ in }, filteredItems: [], filterSelection: "ALL")
}
