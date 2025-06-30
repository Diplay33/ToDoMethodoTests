//
//  SwiftDataRepositoryProtocol.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation
import SwiftData

/// An implementation of the ToDo repository that uses SwiftData for persistence.
class SwiftDataToDoRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getTask(byId id: UUID) throws -> TaskItem {
        let predicate = #Predicate<Item> { $0.id == id }
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)

        guard let item = try context.fetch(fetchDescriptor).first else {
            throw TaskError.taskNotFound(id: id)
        }

        return TaskItem(from: item)
    }

    func saveTask(_ task: TaskItem) throws {
        let itemToSave = Item(from: task)
        context.insert(itemToSave)
        try context.save()
    }
}
