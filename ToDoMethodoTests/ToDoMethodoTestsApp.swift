//
//  ToDoMethodoTestsApp.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import SwiftUI
import SwiftData

@main
struct ToDoMethodoTestsApp: App {
    // MARK: - Exposed Properties

    let sharedModelContainer: ModelContainer

    // MARK: - Initializer

    init() {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            ItemManager.clearAllItems(container: sharedModelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
