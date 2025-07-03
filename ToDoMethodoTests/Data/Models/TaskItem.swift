//
//  TaskItem.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    // MARK: - Exposed Properties

    @Attribute(.unique) var id: UUID
    var title: String
    var itemDescription: String
    var timestamp: Date
    var dueDate: Date?
    var status: TaskStatus
    var statusOrder: Int
    var priority: TaskPriority
    var priorityOrder: Int
    // MARK: - Initializers

    init(id: UUID, title: String, itemDescription: String, timestamp: Date, dueDate: Date?, status: TaskStatus, priority: TaskPriority) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
        self.dueDate = dueDate
        self.status = status
        self.statusOrder = status.sortOrder
        self.priority = priority
        self.priorityOrder = priority.sortOrder
    }

    /// Convenience initializer to map from the business model `ToDoItem`.
    convenience init(from domainModel: TaskItem) {
        self.init(
            id: domainModel.id,
            title: domainModel.title,
            itemDescription: domainModel.description,
            timestamp: domainModel.createdAt,
            dueDate: domainModel.dueDate,
            status: domainModel.status,
            priority: domainModel.priority
        )
    }
}

// MARK: - Models & Errors

/// Represents the status of a task.
enum TaskStatus: String, Codable, CaseIterable {
    case todo = "TODO"
    case inProgress = "ONGOING"
    case done = "DONE"
}

/// Represents the priority of a task
enum TaskPriority: String, Codable, CaseIterable {
    case low = "LOW"
    case normal = "NORMAL"
    case high = "HIGH"
    case critical = "CRITICAL"
}

extension TaskPriority {
    var sortOrder: Int {
        switch self {
            case .low: return 3
            case .normal: return 2
            case .high: return 1
            case .critical: return 0
        }
    }
}

extension TaskStatus {
    var sortOrder: Int {
        switch self {
            case .todo: return 0
            case .inProgress: return 1
            case .done: return 2
        }
    }
}

/// Represents a single task item.
/// The creation logic and validation are handled by its throwing initializer.
struct TaskItem: Equatable {
    var id: UUID
    var title: String
    var description: String
    var createdAt: Date
    var dueDate: Date?
    var status: TaskStatus
    var priority: TaskPriority

    /// Initializer for creating a NEW task with validation.
    init(title: String, description: String = "", creationDate: Date = Date(), dueDate: Date? = nil, priority: TaskPriority = .normal) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { throw TaskError.titleRequired }
        guard trimmedTitle.count <= 100 else { throw TaskError.titleTooLong(count: trimmedTitle.count) }
        guard description.count <= 500 else { throw TaskError.descriptionTooLong(count: description.count) }

        self.id = UUID()
        self.title = trimmedTitle
        self.description = description
        self.createdAt = creationDate
        self.dueDate = dueDate
        self.status = .todo
        self.priority = priority
    }


    /// Initializer for reconstructing an existing task from a persistence model.
    init(from persistenceModel: Item) {
        self.id = persistenceModel.id
        self.title = persistenceModel.title
        self.description = persistenceModel.itemDescription
        self.createdAt = persistenceModel.timestamp
        self.dueDate = persistenceModel.dueDate
        self.status = persistenceModel.status
        self.priority = persistenceModel.priority
    }

    func updating(newTitle: String, newDescription: String) throws -> TaskItem {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { throw TaskError.titleRequired }
        guard trimmedTitle.count <= 100 else { throw TaskError.titleTooLong(count: trimmedTitle.count) }
        guard newDescription.count <= 500 else { throw TaskError.descriptionTooLong(count: newDescription.count) }

        var updatedTask = self
        updatedTask.title = trimmedTitle
        updatedTask.description = newDescription

        return updatedTask
    }

    func updatingStatus(to newStatus: TaskStatus) -> TaskItem {
        var updatedTask = self
        updatedTask.status = newStatus
        return updatedTask
    }

    func updatingDueDate(to newDueDate: Date?) throws -> TaskItem {
        var updatedTask = self
        updatedTask.dueDate = newDueDate
        return updatedTask
    }

    func updatingPriority(to newPriority: TaskPriority) -> TaskItem {
        var updatedTask = self
        updatedTask.priority = newPriority
        return updatedTask
    }
}
