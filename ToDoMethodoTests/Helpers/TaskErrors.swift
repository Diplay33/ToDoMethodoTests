//
//  TaskErrors.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation

/// Defines domain-specific errors for the ToDo feature.
enum TaskError: Error, Equatable, Sendable {
    case titleRequired
    case titleTooLong(count: Int)
    case descriptionTooLong(count: Int)
    case invalidIDFormat
    case taskNotFound(id: UUID)
    case invalidStatus
    case invalidPageParameters
    case invalidSortCriteria
}
