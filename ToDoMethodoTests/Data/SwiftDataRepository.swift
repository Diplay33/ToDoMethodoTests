//
//  SwiftDataRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation
import SwiftData

/// An implementation of the task repository that uses SwiftData for persistence.
final class SwiftDataToDoRepository: TaskRepositoryProtocol {
    // MARK: - Private Properties

    private let context: ModelContext

    // MARK: - Initializers

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Exposed Methods

    func getTask(byId id: UUID) throws -> TaskItem {
        let predicate = #Predicate<Item> { $0.id == id }
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)

        guard let item = try context.fetch(fetchDescriptor).first else {
            throw TaskError.taskNotFound(id: id)
        }

        return TaskItem(from: item)
    }

    func saveTask(_ task: TaskItem) throws {
        let idToFind = task.id
        let predicate = #Predicate<Item> { $0.id == idToFind }
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)

        if let existingItem = try context.fetch(fetchDescriptor).first {
            existingItem.title = task.title
            existingItem.itemDescription = task.description
            existingItem.timestamp = task.createdAt
            existingItem.status = task.status
            existingItem.statusOrder = task.status.sortOrder
        } else {
            let newItem = Item(from: task)
            context.insert(newItem)
        }

        try context.save()
    }

    func deleteTask(byId id: UUID) throws {
        let predicate = #Predicate<Item> { $0.id == id }
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)

        guard let itemToDelete = try context.fetch(fetchDescriptor).first else {
            throw TaskError.taskNotFound(id: id)
        }

        context.delete(itemToDelete)
        try context.save()
    }

    func listTasks(page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem> {
        let totalItemsDescriptor = FetchDescriptor<Item>()
        let totalItems = try context.fetchCount(totalItemsDescriptor)
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        var pageDescriptor = FetchDescriptor<Item>()
        pageDescriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        pageDescriptor.fetchLimit = pageSize
        pageDescriptor.fetchOffset = (page - 1) * pageSize

        let items = try context.fetch(pageDescriptor)

        let taskItems = items.map { TaskItem(from: $0) }

        return PaginatedResult(items: taskItems, metadata: metadata)
    }

    func listTasks(sortBy: TaskSortOption, filterByStatus: TaskStatus?, searchTerm: String?, page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem> {
        let finalPredicate: Predicate<Item>?
        if let status = filterByStatus, let term = searchTerm, !term.isEmpty {
            let statusOrder = status.sortOrder
            finalPredicate = #Predicate<Item> {
                $0.statusOrder == statusOrder &&
                ($0.title.localizedStandardContains(term) || $0.itemDescription.localizedStandardContains(term))
            }
        } else if let status = filterByStatus {
            let statusOrder = status.sortOrder
            finalPredicate = #Predicate<Item> { $0.statusOrder == statusOrder }
        } else if let term = searchTerm, !term.isEmpty {
            finalPredicate = #Predicate<Item> {
                $0.title.localizedStandardContains(term) ||
                $0.itemDescription.localizedStandardContains(term)
            }
        } else {
            finalPredicate = nil
        }

        var descriptor = FetchDescriptor<Item>(predicate: finalPredicate)

        // Apply the correct sorting based on the `sortBy` parameter.
        switch sortBy {
            case .byCreationDate(let order):
                descriptor.sortBy = [SortDescriptor(\.timestamp, order: order == .ascending ? .forward : .reverse)]
            case .byTitle(let order):
                descriptor.sortBy = [SortDescriptor(\.title, order: order == .ascending ? .forward : .reverse)]
            case .byStatus:
                // Sort by status order first, then by date as a secondary criterion.
                descriptor.sortBy = [SortDescriptor(\.statusOrder, order: .forward), SortDescriptor(\.timestamp, order: .reverse)]
        }

        let totalItems = try context.fetchCount(descriptor)
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = (page - 1) * pageSize

        let items = try context.fetch(descriptor)
        let taskItems = items.map { TaskItem(from: $0) }

        return PaginatedResult(items: taskItems, metadata: metadata)
    }
}
