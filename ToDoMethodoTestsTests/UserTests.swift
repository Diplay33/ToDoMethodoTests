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

// MARK: - SwiftData Test Environment for User
@MainActor
struct UserSwiftDataTestEnvironmentFactory {
    static func create() -> (container: ModelContainer, repository: SwiftDataUserRepository) {
        do {
            // The schema now needs to know about the @Model User class.
            let schema = Schema([User.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let repository = SwiftDataUserRepository(context: container.mainContext)
            return (container, repository)
        } catch {
            fatalError("Failed to set up in-memory SwiftData container for Users: \(error)")
        }
    }
}


struct UserTests {

    @MainActor
    struct UserCreationTests {
        var service: UserService
        var repository: MemoryUserRepository

        init() {
            (repository, service) = UserMemoryTestEnvironmentFactory.create()
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

    @MainActor
    struct UserListTests {

        var service: UserService
        var repository: MemoryUserRepository

        init() {
            (repository, service) = UserMemoryTestEnvironmentFactory.create()
            repository.clear()
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

        @Test("Trier les utilisateurs par nom descendant")
        func test_listUsers_sortsByNameDescending() throws {
            // GIVEN
            _ = try service.createUser(name: "Charlie", email: "c@test.com")
            _ = try service.createUser(name: "Alice", email: "a@test.com")
            _ = try service.createUser(name: "Bob", email: "b@test.com")

            // WHEN
            let result = try service.listUsers(sortBy: .byName(order: .descending))

            // THEN
            #expect(result.items.count == 3)
            #expect(result.items.first?.name == "Charlie")
            #expect(result.items.last?.name == "Alice")
        }

        @Test("La pagination des utilisateurs fonctionne correctement")
        func test_listUsers_paginationWorks() throws {
            // GIVEN 22 utilisateurs
            for i in 1...22 {
                let name = String(format: "User %02d", 23-i) // Create in reverse to test sorting
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
            // AND le premier utilisateur de la page 2 est "User 11" (car ils sont triés par nom)
            #expect(result.items.first?.name == "User 11")
        }

        @Test("Lister les utilisateurs quand il n'y en a aucun")
        func test_listUsers_whenEmpty_returnsEmptyResult() throws {
            // GIVEN un repository vide (assuré par le init)

            // WHEN je demande la liste des utilisateurs
            let result = try service.listUsers()

            // THEN j'obtiens une liste vide avec les bonnes métadonnées
            #expect(result.items.isEmpty)
            #expect(result.metadata.totalItems == 0)
            #expect(result.metadata.totalPages == 0)
        }

        @Test("Demander la liste des utilisateurs avec des paramètres de page invalides lève une erreur")
        func test_listUsers_withInvalidPageParams_throwsError() throws {
            #expect(throws: TaskError.invalidPageParameters) {
                _ = try service.listUsers(page: 0)
            }
            #expect(throws: TaskError.invalidPageParameters) {
                _ = try service.listUsers(pageSize: -5)
            }
        }

        @Test("Demander une page d'utilisateurs au-delà des limites retourne une liste vide")
        func test_listUsers_withOutOfBoundsPage_returnsEmptyList() throws {
            // GIVEN
            _ = try service.createUser(name: "Charlie", email: "c@test.com")

            // WHEN
            let result = try service.listUsers(page: 2, pageSize: 10)

            // THEN
            #expect(result.items.isEmpty)
            #expect(result.metadata.totalItems == 1)
            #expect(result.metadata.totalPages == 1)
            #expect(result.metadata.currentPage == 2)
        }
    }

    // MARK: - Integration Tests for SwiftData User Repository

    @MainActor
    struct SwiftDataUserRepositoryTests {
        let container: ModelContainer
        let repository: SwiftDataUserRepository

        init() {
            (container, repository) = UserSwiftDataTestEnvironmentFactory.create()
        }

        @Test("Save a new user and retrieve it successfully by email")
        func test_saveAndRetrieveUserByEmail() throws {
            let newUser = try UserItem(name: "John Swift", email: "john.swift@apple.com")
            try repository.saveUser(newUser)

            let retrievedUser = try repository.findUser(byEmail: "john.swift@apple.com")

            #expect(retrievedUser != nil)
            #expect(retrievedUser?.id == newUser.id)
            #expect(retrievedUser?.name == "John Swift")
        }

        @Test("Finding a non-existent user returns nil")
        func test_findNonExistentUser_returnsNil() throws {
            let retrievedUser = try repository.findUser(byEmail: "nobody@here.com")
            #expect(retrievedUser == nil)
        }

        @Test("Saving a user with an existing ID updates it")
        func test_saveExistingUser_updatesIt() throws {
            let originalUser = try UserItem(name: "Jane Doe", email: "jane@doe.com")
            try repository.saveUser(originalUser)

            let modifiedUser = try UserItem(id: originalUser.id, name: "Jane Smith", email: "jane@smith.com", createdAt: originalUser.createdAt)
            try repository.saveUser(modifiedUser)

            let retrievedUser = try repository.findUser(byEmail: "jane@smith.com")
            #expect(retrievedUser != nil)
            #expect(retrievedUser?.name == "Jane Smith")

            let count = try container.mainContext.fetchCount(FetchDescriptor<User>())
            #expect(count == 1)
        }

        @Test("List users returns paginated and sorted results")
        func test_listUsers_returnsPaginatedAndSorted() throws {
            // GIVEN several users
            try repository.saveUser(try UserItem(name: "Charlie", email: "c@test.com"))
            try repository.saveUser(try UserItem(name: "Alice", email: "a@test.com"))
            try repository.saveUser(try UserItem(name: "Bob", email: "b@test.com"))
            try repository.saveUser(try UserItem(name: "David", email: "d@test.com"))

            // WHEN fetching the first page, sorted descending
            let result = try repository.listUsers(sortBy: .byName(order: .descending), page: 1, pageSize: 3)

            // THEN the results are correct
            #expect(result.items.count == 3)
            #expect(result.metadata.totalItems == 4)
            #expect(result.metadata.totalPages == 2)
            #expect(result.items.first?.name == "David")
            #expect(result.items.last?.name == "Bob")
        }

        @Test("List users with no users returns empty result")
        func test_listUsers_whenEmpty_returnsEmptyResult() throws {
            // GIVEN an empty repository (from init)

            // WHEN listing users
            let result = try repository.listUsers(sortBy: .byName(order: .ascending), page: 1, pageSize: 10)

            // THEN the result is empty
            #expect(result.items.isEmpty)
            #expect(result.metadata.totalItems == 0)
        }
    }
}
