//
//  User.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

struct User: Equatable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date

    /// Initialiseur qui valide les champs de l'utilisateur.
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
