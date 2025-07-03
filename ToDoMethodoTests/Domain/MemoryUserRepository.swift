//
//  MemoryUserRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

final class MemoryUserRepository: UserRepositoryProtocol {
    private var users: [String: UserItem] = [:]

    func saveUser(_ user: UserItem) throws {
        users[user.email] = user
    }

    func findUser(byEmail email: String) throws -> UserItem? {
        return users[email]
    }

    func clear() {
        users = [:]
    }

    func listUsers(sortBy: UserSortOption, page: Int, pageSize: Int) throws -> PaginatedResult<UserItem> {
        var allUsers = Array(users.values)

        switch sortBy {
            case .byName(let order):
                allUsers.sort {
                    let comparisonResult = $0.name.localizedStandardCompare($1.name)
                    if order == .ascending {
                        return comparisonResult == .orderedAscending
                    } else {
                        return comparisonResult == .orderedDescending
                    }
                }
        }

        let totalItems = allUsers.count
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        guard page > 0, page <= metadata.totalPages || totalItems == 0 else {
            return PaginatedResult(items: [], metadata: metadata)
        }

        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalItems)
        let pageItems = Array(allUsers[startIndex..<endIndex])

        return PaginatedResult(items: pageItems, metadata: metadata)
    }
}
