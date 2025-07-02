//
//  TaskSortOption.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

enum SortOrder {
    case ascending
    case descending
}

enum TaskSortOption {
    case byCreationDate(order: SortOrder)
    case byTitle(order: SortOrder)
    case byStatus
}
