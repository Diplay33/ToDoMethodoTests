//
//  TaskService.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation

/// Service layer that encapsulates the main business logic for managing tasks.
final class TaskService {
    private let repository: TaskRepositoryProtocol

    /// Initializes the service with a persistence layer.
    /// - Parameter repository: An object conforming to `SwiftDataToDoRepository`.
    init(repository: TaskRepositoryProtocol) {
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

    func createTask(title: String, description: String = "", priority: TaskPriority = .normal) throws -> TaskItem {
        let newTask = try TaskItem(title: title, description: description, priority: priority)
        try repository.saveTask(newTask)
        return newTask
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

    func changeTaskPriority(byIdString idString: String, newPriority: TaskPriority) throws -> TaskItem {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }
        let originalTask = try repository.getTask(byId: uuid)
        let updatedTask = originalTask.updatingPriority(to: newPriority)
        try repository.saveTask(updatedTask)
        return updatedTask
    }

    func deleteTask(byIdString idString: String) throws {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }

        try repository.deleteTask(byId: uuid)
    }

    func setTaskDueDate(byIdString idString: String, newDueDate: Date?) throws -> TaskItem {
        guard let uuid = UUID(uuidString: idString) else {
            throw TaskError.invalidIDFormat
        }
        let originalTask = try repository.getTask(byId: uuid)
        let updatedTask = try originalTask.updatingDueDate(to: newDueDate)
        try repository.saveTask(updatedTask)
        return updatedTask
    }

    func listTasks(page: Int = 1, pageSize: Int = 20) throws -> PaginatedResult<TaskItem> {
        guard page > 0, pageSize > 0 else {
            throw TaskError.invalidPageParameters
        }
        return try repository.listTasks(page: page, pageSize: pageSize)
    }

    func listTasks(
        sortBy: TaskSortOption = .byCreationDate(order: .descending),
        filterByStatus: TaskStatus? = nil,
        filterByPriority: TaskPriority? = nil,
        searchTerm: String? = nil,
        page: Int = 1,
        pageSize: Int = 20
    ) throws -> PaginatedResult<TaskItem> {
        guard page > 0, pageSize > 0 else {
            throw TaskError.invalidPageParameters
        }

        let trimmedSearchTerm = searchTerm?.trimmingCharacters(in: .whitespacesAndNewlines)

        return try repository.listTasks(
            sortBy: sortBy,
            filterByStatus: filterByStatus,
            filterByPriority: filterByPriority,
            searchTerm: trimmedSearchTerm,
            page: page,
            pageSize: pageSize
        )
    }
}
