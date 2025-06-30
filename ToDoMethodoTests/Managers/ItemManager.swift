//
//  ItemManager.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import Foundation
import SwiftData

enum ItemManager {

    // MARK: - Exposed Methods

    /// Deletes all existing `Item` objects from the persistent store.
    ///
    /// This is a destructive operation and should be used with caution,
    /// primarily for development purposes like resetting the database after a model schema change.
    /// - Parameter container: The `ModelContainer` that manages the app's data store.
    @MainActor static func clearAllItems(container: ModelContainer) {
        let context = container.mainContext

        do {
            try context.delete(model: Item.self, where: #Predicate { _ in true })
            try context.save()
            print("Successfully deleted all items.")
        } catch {
            print("Failed to delete all items: \(error)")
        }
    }
}
