//
//  MemoryRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 01/07/2025.
//

import Foundation

/// An in-memory implementation of the ToDo repository for testing purposes.
/// It simulates the behavior of a real database using a simple dictionary.
final class MemoryRepository {

    // MARK: - Private Properties

    private var tasks: [UUID: TaskItem] = [:]

    // MARK: - Exposed Methods

    /// Retrieves a task by its unique identifier.
    func getTask(byId id: UUID) throws -> TaskItem {
        guard let task = tasks[id] else {
            throw TaskError.taskNotFound(id: id)
        }
        return task
    }

    /// Saves a task. If a task with the same ID already exists, it will be updated.
    func saveTask(_ task: TaskItem) throws {
        // This simple assignment handles both creation and updates in a dictionary.
        tasks[task.id] = task
    }

    /// Deletes a task by its unique identifier.
    func deleteTask(byId id: UUID) throws {
        // `removeValue(forKey:)` returns the removed value, or nil if the key wasn't present.
        guard tasks.removeValue(forKey: id) != nil else {
            throw TaskError.taskNotFound(id: id)
        }
    }

    // MARK: - Helpers

    /// A helper method to clear the repository state between tests if needed.
    func clear() {
        tasks = [:]
    }
}
