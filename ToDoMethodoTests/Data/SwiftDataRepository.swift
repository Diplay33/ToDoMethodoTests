//
//  SwiftDataRepositoryProtocol.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 30/06/2025.
//

import Foundation
import SwiftData

/// An implementation of the task repository that uses SwiftData for persistence.
final class SwiftDataToDoRepository: TaskRepositoryProtocol {
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

    func listTasks(sortBy: TaskSortOption,filterByStatus: TaskStatus?, searchTerm: String?, page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem> {

        let finalPredicate: Predicate<Item>?

        if let status = filterByStatus, let term = searchTerm, !term.isEmpty {
            finalPredicate = #Predicate<Item> {
                $0.status == status &&
                ($0.title.localizedStandardContains(term) || $0.itemDescription.localizedStandardContains(term))
            }
        } else if let status = filterByStatus {
            finalPredicate = #Predicate<Item> { $0.status == status }
        } else if let term = searchTerm, !term.isEmpty {
            finalPredicate = #Predicate<Item> {
                $0.title.localizedStandardContains(term) ||
                $0.itemDescription.localizedStandardContains(term)
            }
        } else {
            finalPredicate = nil
        }

        var descriptor = FetchDescriptor<Item>(predicate: finalPredicate)

        switch sortBy {
            case .byCreationDate(let order):
                descriptor.sortBy = [SortDescriptor(\.timestamp, order: order == .ascending ? .forward : .reverse)]
            case .byTitle(let order):
                descriptor.sortBy = [SortDescriptor(\.title, order: order == .ascending ? .forward : .reverse)]
            case .byStatus:
                descriptor.sortBy = [SortDescriptor(\.statusOrder, order: .forward)]
        }

        let totalItems = try context.fetchCount(descriptor)
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = (page - 1) * pageSize

        let items = try context.fetch(descriptor)

        let taskItems = items.map { TaskItem(from: $0) }

        return PaginatedResult(items: taskItems, metadata: metadata)
    }
}
