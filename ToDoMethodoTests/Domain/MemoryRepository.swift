//
//  MemoryRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 01/07/2025.
//

import Foundation

/// An in-memory implementation of the task repository for testing purposes.
/// It simulates the behavior of a real database using a simple dictionary.
final class MemoryRepository: TaskRepositoryProtocol {

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
        guard tasks.removeValue(forKey: id) != nil else {
            throw TaskError.taskNotFound(id: id)
        }
    }

    // MARK: - Helpers

    /// A helper method to clear the repository state between tests if needed.
    func clear() {
        tasks = [:]
    }

    func listTasks(page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem> {
        let allTasks = tasks.values.sorted { $0.createdAt > $1.createdAt }
        let totalItems = allTasks.count

        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        guard page > 0, page <= metadata.totalPages || totalItems == 0 else {
            return PaginatedResult(items: [], metadata: metadata)
        }

        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalItems)

        let pageItems = Array(allTasks[startIndex..<endIndex])

        return PaginatedResult(items: pageItems, metadata: metadata)
    }

    func listTasks(
        sortBy: TaskSortOption,
        filterByStatus: TaskStatus?,
        filterByPriority: TaskPriority?,
        searchTerm: String?,
        page: Int,
        pageSize: Int
    ) throws -> PaginatedResult<TaskItem> {

        var resultTasks = Array(tasks.values)

        if let status = filterByStatus {
            resultTasks = resultTasks.filter { $0.status == status }
        }

        if let priority = filterByPriority {
            resultTasks = resultTasks.filter { $0.priority == priority }
        }

        if let term = searchTerm, !term.isEmpty {
            resultTasks = resultTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(term) ||
                task.description.localizedCaseInsensitiveContains(term)
            }
        }

        switch sortBy {
            case .byCreationDate(let order):
                resultTasks.sort {
                    if order == .ascending {
                        return $0.createdAt < $1.createdAt
                    } else {
                        return $0.createdAt > $1.createdAt
                    }
                }
            case .byTitle(let order):
                resultTasks.sort {
                    let comparisonResult = $0.title.localizedStandardCompare($1.title)
                    if order == .ascending {
                        return comparisonResult == .orderedAscending
                    } else {
                        return comparisonResult == .orderedDescending
                    }
                }
            case .byStatus:
                resultTasks.sort { $0.status.sortOrder < $1.status.sortOrder }
            case .byPriority(let order):
                resultTasks.sort {
                    if order == .ascending {
                        return $0.priority.sortOrder < $1.priority.sortOrder
                    } else {
                        return $0.priority.sortOrder > $1.priority.sortOrder
                    }
                }
        }

        let totalItems = resultTasks.count
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        guard page > 0, page <= metadata.totalPages || totalItems == 0 else {
            return PaginatedResult(items: [], metadata: metadata)
        }

        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalItems)
        let pageItems = Array(resultTasks[startIndex..<endIndex])

        return PaginatedResult(items: pageItems, metadata: metadata)
    }
}
