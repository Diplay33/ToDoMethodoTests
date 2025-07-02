//
//  TaskRepositoryProtocol.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 01/07/2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    func getTask(byId id: UUID) throws -> TaskItem
    func saveTask(_ task: TaskItem) throws
    func deleteTask(byId id: UUID) throws
    func listTasks(page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem>
    func listTasks(sortBy: TaskSortOption, filterByStatus: TaskStatus?, searchTerm: String?, page: Int, pageSize: Int) throws -> PaginatedResult<TaskItem>
}
