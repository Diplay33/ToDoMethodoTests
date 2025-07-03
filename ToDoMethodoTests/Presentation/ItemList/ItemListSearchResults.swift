//
//  ItemListSearchResults.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 03/07/2025.
//

import SwiftUI

struct ItemListSearchResults: View {
    var searchText: String
    var filteredItems: [Item]
    var deleteItems: (IndexSet) -> Void
    
    var body: some View {
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
}

#Preview {
    ItemListSearchResults(searchText: "", filteredItems: [], deleteItems: { _ in })
}
