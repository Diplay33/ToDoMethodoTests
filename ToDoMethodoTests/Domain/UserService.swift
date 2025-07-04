//
//  UserService.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

final class UserService {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    /// Crée un nouvel utilisateur après avoir validé l'unicité de l'email et la syntaxe des champs.
    func createUser(name: String, email: String) throws -> UserItem {
        if try repository.findUser(byEmail: email) != nil {
            throw UserError.emailAlreadyInUse
        }

        let newUser = try UserItem(name: name, email: email)

        try repository.saveUser(newUser)

        return newUser
    }

    func listUsers(
        sortBy: UserSortOption = .byName(order: .ascending),
        page: Int = 1,
        pageSize: Int = 20
    ) throws -> PaginatedResult<UserItem> {
        guard page > 0, pageSize > 0 else {
            throw TaskError.invalidPageParameters
        }

        return try repository.listUsers(sortBy: sortBy, page: page, pageSize: pageSize)
    }
}
