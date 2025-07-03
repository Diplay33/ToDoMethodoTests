//
//  UserItem.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

struct UserItem: Equatable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date

    /// Initializer that validates the user's fields.
    init(id: UUID = UUID(), name: String, email: String, createdAt: Date = Date()) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw UserError.nameRequired }
        guard trimmedName.count <= 50 else { throw UserError.nameTooLong(count: trimmedName.count) }

        guard email.contains("@") && email.contains(".") else { throw UserError.invalidEmailFormat }

        self.id = id
        self.name = trimmedName
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - Helpers

extension UserItem {
    /// Initializer for reconstructing a UserItem from a persistence model.
    init(from persistenceModel: User) {
        self.id = persistenceModel.id
        self.name = persistenceModel.name
        self.email = persistenceModel.email
        self.createdAt = persistenceModel.createdAt
    }
}
