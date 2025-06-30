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

    var title: String = ""
    var itemDescription: String = ""

    var timestamp: Date

    // MARK: - Initializer

    init(title: String, itemDescription: String, timestamp: Date) {
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
    }
}

// MARK: - Models & Errors

/// Represents the status of a task.
enum TaskStatus: String, Codable {
    case todo = "TODO"
    case inProgress = "IN PROGRESS"
    case done = "DONE"
}

/// Defines the specific errors that can occur during task creation.
enum TaskValidationError: Error, Equatable {
    case titleRequired
    case titleTooLong(count: Int)
    case descriptionTooLong(count: Int)
}

/// Represents a single task item.
/// The creation logic and validation are handled by its throwing initializer.
struct TaskItem {
    let id: UUID
    let title: String
    let description: String
    let createdAt: Date
    let status: TaskStatus

    /// Creates a new `ToDoItem` after validating the input.
    ///
    /// - Throws: `TaskValidationError` if any validation rule fails.
    init(
        title: String,
        description: String = "",
        creationDate: Date = Date()
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        // Rule: Title is required
        guard !trimmedTitle.isEmpty else {
            throw TaskValidationError.titleRequired
        }

        // Rule: Title max 100 chars
        guard trimmedTitle.count <= 100 else {
            throw TaskValidationError.titleTooLong(count: trimmedTitle.count)
        }

        // Rule: Description max 500 chars
        guard description.count <= 500 else {
            throw TaskValidationError.descriptionTooLong(count: description.count)
        }

        self.id = UUID()
        self.title = trimmedTitle
        self.description = description
        self.createdAt = creationDate
        self.status = .todo
    }
}
