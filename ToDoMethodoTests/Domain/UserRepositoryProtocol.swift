//
//  UserRepositoryProtocol.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

protocol UserRepositoryProtocol {
    /// Sauvegarde un utilisateur (création ou mise à jour).
    func saveUser(_ user: UserItem) throws

    /// Trouve un utilisateur par son email. Retourne nil s'il n'est pas trouvé.
    func findUser(byEmail email: String) throws -> UserItem?

    /// Liste les utilisateurs avec tri et pagination.
    func listUsers(sortBy: UserSortOption, page: Int, pageSize: Int) throws -> PaginatedResult<UserItem>
}
