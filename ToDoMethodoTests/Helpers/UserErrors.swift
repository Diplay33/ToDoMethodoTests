//
//  UserErrors.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Foundation

/// Définit les erreurs spécifiques au domaine Utilisateur.
enum UserError: Error, Equatable, Sendable {
    case nameRequired
    case nameTooLong(count: Int)
    case invalidEmailFormat
    case emailAlreadyInUse
}
