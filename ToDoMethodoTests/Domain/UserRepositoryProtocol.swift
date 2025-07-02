//
//  UserRepositoryProtocol.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

protocol UserRepositoryProtocol {
    /// Sauvegarde un utilisateur (création ou mise à jour).
    func saveUser(_ user: User) throws

    /// Trouve un utilisateur par son email. Retourne nil s'il n'est pas trouvé.
    func findUser(byEmail email: String) throws -> User?
}
