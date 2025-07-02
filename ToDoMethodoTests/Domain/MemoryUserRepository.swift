//
//  MemoryUserRepository.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

final class MemoryUserRepository: UserRepositoryProtocol {
    private var users: [String: User] = [:]

    func saveUser(_ user: User) throws {
        users[user.email] = user
    }

    func findUser(byEmail email: String) throws -> User? {
        return users[email]
    }

    func clear() {
        users = [:]
    }
}
