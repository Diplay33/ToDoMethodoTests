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

    struct UserCreationTests {
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
    
    struct UserListTests {

        var service: UserService
        var repository: MemoryUserRepository

        init() {
            repository = MemoryUserRepository()
            service = UserService(repository: repository)
        }

        @Test("Lister les utilisateurs les trie par nom par défaut")
        func test_listUsers_defaultSortsByNameAscending() throws {
            // GIVEN plusieurs utilisateurs dans le désordre
            _ = try service.createUser(name: "Charlie", email: "c@test.com")
            _ = try service.createUser(name: "Alice", email: "a@test.com")
            _ = try service.createUser(name: "Bob", email: "b@test.com")

            // WHEN je demande la liste sans spécifier de tri
            let result = try service.listUsers()

            // THEN j'obtiens tous les utilisateurs
            #expect(result.items.count == 3)
            // AND ils sont triés par nom par défaut
            #expect(result.items.first?.name == "Alice")
            #expect(result.items.last?.name == "Charlie")
        }

        @Test("La pagination des utilisateurs fonctionne correctement")
        func test_listUsers_paginationWorks() throws {
            // GIVEN 22 utilisateurs
            for i in 1...22 {
                let name = String(format: "User %02d", i)
                _ = try service.createUser(name: name, email: "\(i)@test.com")
            }

            // WHEN je demande la deuxième page avec une taille de 10
            let result = try service.listUsers(page: 2, pageSize: 10)

            // THEN j'obtiens 10 utilisateurs
            #expect(result.items.count == 10)
            // AND les métadonnées sont correctes
            #expect(result.metadata.currentPage == 2)
            #expect(result.metadata.totalItems == 22)
            #expect(result.metadata.totalPages == 3)
            // AND le premier utilisateur de la page 2 est "User 11"
            #expect(result.items.first?.name == "User 11")
        }

        @Test("Lister les utilisateurs quand il n'y en a aucun")
        func test_listUsers_whenEmpty_returnsEmptyResult() throws {
            // GIVEN un repository vide

            // WHEN je demande la liste des utilisateurs
            let result = try service.listUsers()

            // THEN j'obtiens une liste vide avec les bonnes métadonnées
            #expect(result.items.isEmpty)
            #expect(result.metadata.totalItems == 0)
            #expect(result.metadata.totalPages == 0)
        }
    }
}






