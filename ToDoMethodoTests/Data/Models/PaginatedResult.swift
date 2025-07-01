//
//  PaginatedResult.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 01/07/2025.
//

import Foundation

/// Contient les métadonnées pour une liste paginée.
struct PaginationMetadata: Equatable {
    let currentPage: Int
    let pageSize: Int
    let totalItems: Int

    /// Le nombre total de pages, calculé dynamiquement.
    var totalPages: Int {
        guard pageSize > 0, totalItems > 0 else { return 0 }
        return Int(ceil(Double(totalItems) / Double(pageSize)))
    }
}

/// Une structure générique qui contient une page d'éléments et ses métadonnées de pagination.
struct PaginatedResult<T>: Equatable where T: Equatable {
    let items: [T]
    let metadata: PaginationMetadata
}
