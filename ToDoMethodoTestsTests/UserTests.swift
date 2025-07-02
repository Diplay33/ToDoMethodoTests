//
//  UserTests.swift
//  ToDoMethodoTests
//
//  Created by KILLIAN ADONAI on 02/07/2025.
//

import Testing
import SwiftData
@testable import ToDoMethodoTests
import Foundation

@MainActor
struct UserMemoryTestEnvironmentFactory {
    static func create() -> (repository: MemoryUserRepository,service: UserService) {
        let repository = MemoryUserRepository()
        let service = UserService(repository: repository)
        return (repository, service)
    }
}

struct UserTests {

    var service: UserService
    var repository: MemoryUserRepository

    init() {
        repository = MemoryUserRepository()
        service = UserService(repository: repository)
    }

    @Test("Créer un utilisateur avec des données valides")
    func test_createUser_withValidData_succeeds() throws {
        // WHEN je crée un utilisateur avec des données valides
        let user = try service.createUser(name: "John Doe", email: "john.doe@test.com")

        // THEN l'utilisateur est créé avec les bonnes informations
        #expect(user.name == "John Doe")
        #expect(user.email == "john.doe@test.com")
        #expect(!user.id.uuidString.isEmpty)
    }

    @Test("Tenter de créer un utilisateur avec un email existant")
    func test_createUser_withDuplicateEmail_throwsError() throws {
        // GIVEN un utilisateur existant
        _ = try service.createUser(name: "Jane Doe", email: "jane.doe@test.com")

        // WHEN je tente de créer un autre utilisateur avec le même email
        // THEN j'obtiens une erreur 'emailAlreadyInUse'
        #expect(throws: UserError.emailAlreadyInUse) {
            try service.createUser(name: "John Doe", email: "jane.doe@test.com")
        }
    }

    @Test("Tenter de créer un utilisateur avec un email invalide")
    func test_createUser_withInvalidEmailFormat_throwsError() throws {
        #expect(throws: UserError.invalidEmailFormat) {
            try service.createUser(name: "John Doe", email: "email-invalide")
        }
    }

    @Test("Tenter de créer un utilisateur avec un nom vide")
    func test_createUser_withEmptyName_throwsError() throws {
        #expect(throws: UserError.nameRequired) {
            try service.createUser(name: "  ", email: "john.doe@test.com")
        }
    }

    @Test("Tenter de créer un utilisateur avec un nom trop long")
    func test_createUser_withLongName_throwsError() throws {
        let longName = String(repeating: "a", count: 51)
        #expect(throws: UserError.nameTooLong(count: 51)) {
            try service.createUser(name: longName, email: "john.doe@test.com")
        }
    }
}






