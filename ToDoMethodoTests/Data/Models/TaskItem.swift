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
    var status: TaskStatus

    // MARK: - Initializers

    init(id: UUID, title: String, itemDescription: String, timestamp: Date, status: TaskStatus) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
        self.status = status
    }

    /// Convenience initializer to map from the business model `ToDoItem`.
    convenience init(from domainModel: TaskItem) {
        self.init(
            id: domainModel.id,
            title: domainModel.title,
            itemDescription: domainModel.description,
            timestamp: domainModel.createdAt,
            status: domainModel.status
        )
    }
}

// MARK: - Models & Errors

/// Represents the status of a task.
enum TaskStatus: String, Codable {
    case todo = "TODO"
    case inProgress = "IN PROGRESS"
    case done = "DONE"
}

/// Represents a single task item.
/// The creation logic and validation are handled by its throwing initializer.
struct TaskItem {
    var id: UUID
    var title: String
    var description: String
    var createdAt: Date
    var status: TaskStatus

    /// Initializer for creating a NEW task with validation.
    init(title: String, description: String = "", creationDate: Date = Date()) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { throw TaskError.titleRequired }
        guard trimmedTitle.count <= 100 else { throw TaskError.titleTooLong(count: trimmedTitle.count) }
        guard description.count <= 500 else { throw TaskError.descriptionTooLong(count: description.count) }

        self.id = UUID()
        self.title = trimmedTitle
        self.description = description
        self.createdAt = creationDate
        self.status = .todo
    }

    /// Initializer for reconstructing an existing task from a persistence model.
    init(from persistenceModel: Item) {
        self.id = persistenceModel.id
        self.title = persistenceModel.title
        self.description = persistenceModel.itemDescription
        self.createdAt = persistenceModel.timestamp
        self.status = persistenceModel.status
    }
}
