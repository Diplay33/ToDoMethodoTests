//
//  TaskService.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation

/// Service layer that encapsulates the main business logic for managing tasks.
final class TaskService {
    private let repository: SwiftDataToDoRepository

    /// Initializes the service with a persistence layer.
    /// - Parameter repository: An object conforming to `SwiftDataToDoRepository`.
    init(repository: SwiftDataToDoRepository) {
        self.repository = repository
    }

    /// Finds a task by its ID string.
    /// This method handles ID format validation before querying the repository.
    /// - Parameter idString: The string representation of the task's UUID.
    /// - Returns: The found `TaskItem`.
    /// - Throws: `ToDoError.invalidIDFormat` or `ToDoError.taskNotFound`.
    func findTask(byIdString idString: String) throws -> TaskItem {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }

        return try repository.getTask(byId: uuid)
    }

    func updateTask(
        byIdString idString: String,
        newTitle: String,
        newDescription: String
    ) throws -> TaskItem {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }
        let originalTask = try repository.getTask(byId: uuid)
        let updatedTask = try originalTask.updating(newTitle: newTitle, newDescription: newDescription)
        try repository.saveTask(updatedTask)
        return updatedTask
    }

    func changeTaskStatus(byIdString idString: String, newStatus: TaskStatus) throws -> TaskItem {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }
        let originalTask = try repository.getTask(byId: uuid)
        let updatedTask = originalTask.updatingStatus(to: newStatus)
        try repository.saveTask(updatedTask)
        return updatedTask
    }

    func deleteTask(byIdString idString: String) throws {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }

        try repository.deleteTask(byId: uuid)
    }
}
