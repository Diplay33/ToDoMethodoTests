//
//  ToDoMethodoTestsTests.swift
//  ToDoMethodoTestsTests
//
//  Created by Jacques HU on 30/06/2025.
//

import Testing
import SwiftData
@testable import ToDoMethodoTests
import Foundation

// MARK: - Unit Tests for TaskItem Creation

struct TaskItemCreationTests {

    @Test("Création avec un titre valide")
    func test_createTask_withValidTitle_isCreatedCorrectly() throws {
        let task = try TaskItem(title: "Apprendre les tests unitaires")
        #expect(task.title == "Apprendre les tests unitaires")
        #expect(task.description.isEmpty)
        #expect(task.status == .todo)
    }

    @Test("Création avec un titre et une description valides")
    func test_createTask_withValidTitleAndDescription_isCreatedCorrectly() throws {
        let task = try TaskItem(title: "Planifier les vacances", description: "Réserver les billets d'avion et l'hôtel.")
        #expect(task.title == "Planifier les vacances")
        #expect(task.description == "Réserver les billets d'avion et l'hôtel.")
    }

    @Test("Tentative de création avec un titre vide ou blanc")
    func test_createTask_withEmptyTitle_throwsError() throws {
        #expect(throws: TaskError.titleRequired) {
            try TaskItem(title: "")
        }
        #expect(throws: TaskError.titleRequired) {
            try TaskItem(title: "   ")
        }
    }

    @Test("Tentative de création avec un titre trop long")
    func test_createTask_withOversizedTitle_throwsError() throws {
        let longTitle = String(repeating: "x", count: 101)
        #expect(throws: TaskError.titleTooLong(count: 101)) {
            try TaskItem(title: longTitle)
        }
    }

    @Test("Tentative de création avec une description trop longue")
    func test_createTask_withOversizedDescription_throwsError() throws {
        let longDescription = String(repeating: "y", count: 501)
        #expect(throws: TaskError.descriptionTooLong(count: 501)) {
            try TaskItem(title: "Titre valide", description: longDescription)
        }
    }

    @Test("Création avec un titre contenant des espaces en trop")
    func test_createTask_withSpacedTitle_trimsSpaces() throws {
        let task = try TaskItem(title: "  Nettoyer le garage  ")
        #expect(task.title == "Nettoyer le garage")
    }

    @Test("Vérification de la précision de la date de création")
    func test_taskCreationDate_isAccurate() throws {
        let beforeCreation = Date()
        let task = try TaskItem(title: "Vérifier l'heure")
        let afterCreation = Date()
        #expect(task.createdAt >= beforeCreation)
        #expect(task.createdAt <= afterCreation)
    }
}

@MainActor
struct TaskItemReadTests {
    let container: ModelContainer
    let repository: SwiftDataToDoRepository
    let service: TaskService

    init() {
        do {
            let schema = Schema([Item.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            repository = SwiftDataToDoRepository(context: container.mainContext)
            service = TaskService(repository: repository)
        } catch {
            fatalError("Failed to set up in-memory SwiftData container: \(error)")
        }
    }

    @Test("Consulter une tâche existante avec un ID valide")
    func test_findTask_withValidID_returnsTaskDetails() throws {
        // GIVEN une tâche existante et son ID valide sous forme de chaîne
        let existingTask = try TaskItem(title: "Tâche à retrouver", description: "Détails importants")
        try repository.saveTask(existingTask)
        let validIDString = existingTask.id.uuidString

        // WHEN je consulte cette tâche via le service
        let foundTask = try service.findTask(byIdString: validIDString)

        // THEN j'obtiens tous ses détails correspondants
        #expect(foundTask.id == existingTask.id)
        #expect(foundTask.title == "Tâche à retrouver")
        #expect(foundTask.description == "Détails importants")
        #expect(foundTask.status == .todo)
        #expect(foundTask.createdAt == existingTask.createdAt)
    }

    @Test("Consulter une tâche avec un ID inexistant")
    func test_findTask_withNonExistentID_throwsNotFoundError() throws {
        // GIVEN un ID de format valide mais qui n'existe pas dans le repository
        let nonExistentID = UUID()

        // WHEN je tente de consulter la tâche avec cet ID
        // THEN j'obtiens une erreur 'taskNotFound'
        #expect(throws: TaskError.taskNotFound(id: nonExistentID)) {
            try service.findTask(byIdString: nonExistentID.uuidString)
        }
    }

    @Test("Consulter une tâche avec un ID au mauvais format")
    func test_findTask_withInvalidIDFormat_throwsInvalidFormatError() throws {
        // GIVEN un ID au mauvais format
        let invalidIDString = "ceci-nest-pas-un-uuid"

        // WHEN je tente de consulter la tâche avec cet ID
        // THEN j'obtiens une erreur 'invalidIDFormat'
        #expect(throws: TaskError.invalidIDFormat) {
            try service.findTask(byIdString: invalidIDString)
        }
    }
}

@MainActor
struct TaskItemEditTests {
    let container: ModelContainer
    let repository: SwiftDataToDoRepository
    let service: TaskService

    init() {
        do {
            let schema = Schema([Item.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            repository = SwiftDataToDoRepository(context: container.mainContext)
            service = TaskService(repository: repository)
        } catch {
            fatalError("Failed to set up in-memory SwiftData container: \(error)")
        }
    }

    @Test("Modifier le titre d'une tâche existante")
    func test_updateTask_withValidNewTitle_succeeds() throws {
        // GIVEN une tâche existante
        let originalTask = try TaskItem(title: "Titre Original", description: "Description Originale")
        try repository.saveTask(originalTask)

        // WHEN je modifie son titre avec une valeur valide
        let updatedTask = try service.updateTask(
            byIdString: originalTask.id.uuidString,
            newTitle: "Nouveau Titre",
            newDescription: "Description Originale" // La description ne change pas
        )

        // THEN le nouveau titre est sauvegardé
        #expect(updatedTask.title == "Nouveau Titre")
        // AND les autres champs sont inchangés
        #expect(updatedTask.description == "Description Originale")
        #expect(updatedTask.id == originalTask.id)
        #expect(updatedTask.createdAt == originalTask.createdAt)
    }

    @Test("Modifier la description d'une tâche existante")
    func test_updateTask_withValidNewDescription_succeeds() throws {
        let originalTask = try TaskItem(title: "Titre Original", description: "Description Originale")
        try repository.saveTask(originalTask)

        let updatedTask = try service.updateTask(
            byIdString: originalTask.id.uuidString,
            newTitle: "Titre Original",
            newDescription: "Nouvelle Description"
        )

        #expect(updatedTask.title == "Titre Original")
        #expect(updatedTask.description == "Nouvelle Description")
    }

    @Test("Modifier le titre et la description d'une tâche")
    func test_updateTask_withValidNewTitleAndDescription_succeeds() throws {
        let originalTask = try TaskItem(title: "Titre Original", description: "Description Originale")
        try repository.saveTask(originalTask)

        let updatedTask = try service.updateTask(
            byIdString: originalTask.id.uuidString,
            newTitle: "Nouveau Titre",
            newDescription: "Nouvelle Description"
        )

        #expect(updatedTask.title == "Nouveau Titre")
        #expect(updatedTask.description == "Nouvelle Description")
    }

    @Test("Tenter de modifier une tâche avec un titre vide")
    func test_updateTask_withEmptyTitle_throwsError() throws {
        let originalTask = try TaskItem(title: "Titre Original")
        try repository.saveTask(originalTask)

        #expect(throws: TaskError.titleRequired) {
            try service.updateTask(
                byIdString: originalTask.id.uuidString,
                newTitle: "",
                newDescription: "Description quelconque"
            )
        }
    }

    @Test("Tenter de modifier une tâche avec des valeurs trop longues")
    func test_updateTask_withOversizedValues_throwsError() throws {
        let originalTask = try TaskItem(title: "Titre Original")
        try repository.saveTask(originalTask)
        let longString101 = String(repeating: "x", count: 101)
        let longString501 = String(repeating: "y", count: 501)

        // Test du titre trop long
        #expect(throws: TaskError.titleTooLong(count: 101)) {
            try service.updateTask(byIdString: originalTask.id.uuidString, newTitle: longString101, newDescription: "")
        }

        // Test de la description trop longue
        #expect(throws: TaskError.descriptionTooLong(count: 501)) {
            try service.updateTask(byIdString: originalTask.id.uuidString, newTitle: "Titre Valide", newDescription: longString501)
        }
    }

    @Test("Tenter de modifier une tâche inexistante")
    func test_updateTask_withNonExistentID_throwsNotFoundError() throws {
        let nonExistentID = UUID().uuidString

        #expect(throws: TaskError.taskNotFound(id: UUID(uuidString: nonExistentID)!)) {
            try service.updateTask(
                byIdString: nonExistentID,
                newTitle: "Nouveau Titre",
                newDescription: "Nouvelle Description"
            )
        }
    }
}

// MARK: - Integration Tests for SwiftData Repository

@MainActor
struct SwiftDataRepositoryIntegrationTests {

    let container: ModelContainer
    let repository: SwiftDataToDoRepository

    init() {
        do {
            let schema = Schema([Item.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            repository = SwiftDataToDoRepository(context: container.mainContext)
        } catch {
            fatalError("Failed to set up in-memory SwiftData container: \(error)")
        }
    }

    @Test("Save a new task and retrieve it successfully")
    func test_saveAndRetrieveTask() throws {
        let newTask = try TaskItem(title: "Test Integration", description: "My Description")
        try repository.saveTask(newTask)
        let retrievedTask = try repository.getTask(byId: newTask.id)

        #expect(retrievedTask.id == newTask.id)
        #expect(retrievedTask.title == "Test Integration")
        #expect(retrievedTask.description == "My Description")
    }

    @Test("Attempting to retrieve a non-existent task throws an error")
    func test_getNonExistentTask_throwsNotFoundError() throws {
        let nonExistentID = UUID()
        #expect(throws: TaskError.taskNotFound(id: nonExistentID)) {
            try repository.getTask(byId: nonExistentID)
        }
    }

    @Test("Saving a task with an existing ID updates the task")
    func test_saveExistingTask_updatesIt() throws {
        let originalTask = try TaskItem(title: "Original Title")
        try repository.saveTask(originalTask)

        var modifiedTask = originalTask
        modifiedTask.title = "Updated Title"
        try repository.saveTask(modifiedTask)

        let retrievedTask = try repository.getTask(byId: originalTask.id)
        #expect(retrievedTask.title == "Updated Title")

        let idToFind = originalTask.id
        let predicate = #Predicate<Item> { $0.id == idToFind }
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)
        let count = try container.mainContext.fetchCount(fetchDescriptor)
        #expect(count == 1)
    }
}
