//
//  SwiftDataUserRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 03/07/2025.
//

import Foundation
import SwiftData

final class SwiftDataUserRepository: UserRepositoryProtocol {
    // MARK: - Private Properties

    private let context: ModelContext

    // MARK: - Initializers

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Exposed Methods

    func saveUser(_ user: UserItem) throws {
        let idToFind = user.id
        let predicate = #Predicate<User> { $0.id == idToFind }
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)

        if let existingUser = try context.fetch(fetchDescriptor).first {
            existingUser.name = user.name
            existingUser.email = user.email
            existingUser.createdAt = user.createdAt
        } else {
            let newUser = User(from: user)
            context.insert(newUser)
        }
        try context.save()
    }

    func findUser(byEmail email: String) throws -> UserItem? {
        let predicate = #Predicate<User> { $0.email == email }
        var fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        fetchDescriptor.fetchLimit = 1

        guard let persistentUser = try context.fetch(fetchDescriptor).first else {
            return nil
        }
        return UserItem(from: persistentUser)
    }

    func listUsers(sortBy: UserSortOption, page: Int, pageSize: Int) throws -> PaginatedResult<UserItem> {
        var descriptor = FetchDescriptor<User>()

        switch sortBy {
            case .byName(let order):
                descriptor.sortBy = [SortDescriptor(\.name, order: order == .ascending ? .forward : .reverse)]
        }

        let totalItems = try context.fetchCount(descriptor)
        let metadata = PaginationMetadata(currentPage: page, pageSize: pageSize, totalItems: totalItems)

        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = (page - 1) * pageSize

        let persistentUsers = try context.fetch(descriptor)
        let users = persistentUsers.map { UserItem(from: $0) }

        return PaginatedResult(items: users, metadata: metadata)
    }
}
