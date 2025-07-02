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
    func createUser(name: String, email: String) throws -> User {
        if try repository.findUser(byEmail: email) != nil {
            throw UserError.emailAlreadyInUse
        }

        let newUser = try User(name: name, email: email)

        try repository.saveUser(newUser)

        return newUser
    }
}
