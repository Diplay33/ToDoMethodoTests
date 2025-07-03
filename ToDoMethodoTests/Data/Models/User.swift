//
//  User.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 03/07/2025.
//

import Foundation
import SwiftData

@Model
final class User {
    // MARK: - Exposed Properties

    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.unique) var email: String
    var createdAt: Date

    // MARK: - Initializers

    init(id: UUID, name: String, email: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - Helpers

extension User {
    /// Convenience initializer to map from the business model `UserItem`.
    convenience init(from domainModel: UserItem) {
        self.init(
            id: domainModel.id,
            name: domainModel.name,
            email: domainModel.email,
            createdAt: domainModel.createdAt
        )
    }
}
