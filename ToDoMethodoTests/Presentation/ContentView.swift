//
//  ContentView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ItemListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
