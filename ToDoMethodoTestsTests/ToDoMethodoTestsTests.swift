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

@MainActor
struct TestEnvironmentFactory {
    static func create() -> (container: ModelContainer, repository: SwiftDataToDoRepository, service: TaskService) {
        do {
            let schema = Schema([Item.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let repository = SwiftDataToDoRepository(context: container.mainContext)
            let service = TaskService(repository: repository)
            return (container, repository, service)
        } catch {
            fatalError("Échec de la création du conteneur SwiftData en mémoire : \(error)")
        }
    }
}

struct TaskTests {
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
            (container, repository, service) = TestEnvironmentFactory.create()
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
            (container, repository, service) = TestEnvironmentFactory.create()
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
                newDescription: "Description Originale"
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

            #expect(throws: TaskError.titleTooLong(count: 101)) {
                try service.updateTask(byIdString: originalTask.id.uuidString, newTitle: longString101, newDescription: "")
            }

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

    @MainActor
    struct TaskItemEditStatusTests {
        let container: ModelContainer
        let repository: SwiftDataToDoRepository
        let service: TaskService

        init() {
            (container, repository, service) = TestEnvironmentFactory.create()
        }

        @Test("Changer le statut d'une tâche existante")
        func test_changeStatus_withValidStatus_succeeds() throws {
            // GIVEN une tâche existante avec le statut 'TODO'
            let originalTask = try TaskItem(title: "Ma Tâche")
            try repository.saveTask(originalTask)
            #expect(originalTask.status == .todo)

            // WHEN je change son statut vers 'ONGOING'
            let updatedTask = try service.changeTaskStatus(
                byIdString: originalTask.id.uuidString,
                newStatus: .inProgress
            )

            // THEN le statut est bien mis à jour
            #expect(updatedTask.status == .inProgress)

            // AND la modification est bien persistée
            let persistedTask = try repository.getTask(byId: originalTask.id)
            #expect(persistedTask.status == .inProgress)
        }

        @Test("Tenter de créer un statut avec une valeur invalide")
        func test_taskStatusInit_fromInvalidRawValue_returnsNil() throws {
            // GIVEN une chaîne de caractères qui ne correspond à aucun statut valide
            let invalidStatusString = "PENDING"

            // WHEN je tente de créer un TaskStatus à partir de cette chaîne
            let status = TaskStatus(rawValue: invalidStatusString)

            // THEN l'initialisation échoue et retourne nil
            #expect(status == nil)
        }

        @Test("Tenter de changer le statut d'une tâche inexistante")
        func test_changeStatus_ofNonExistentTask_throwsNotFoundError() throws {
            // GIVEN un ID qui ne correspond à aucune tâche
            let nonExistentID = UUID()

            // WHEN je tente de changer le statut pour cet ID
            // THEN j'obtiens une erreur 'taskNotFound'
            #expect(throws: TaskError.taskNotFound(id: nonExistentID)) {
                try service.changeTaskStatus(
                    byIdString: nonExistentID.uuidString,
                    newStatus: .done
                )
            }
        }
    }

    @MainActor
    struct TaskDeleteTests {
        let container: ModelContainer
        let repository: SwiftDataToDoRepository
        let service: TaskService

        init() {
            (container, repository, service) = TestEnvironmentFactory.create()
        }

        @Test("Supprimer une tâche existante avec succès")
        func test_deleteExistingTask_removesItFromPersistence() throws {
            // GIVEN une tâche existante sauvegardée
            let taskToDelete = try TaskItem(title: "Tâche à supprimer")
            try repository.saveTask(taskToDelete)

            // Je vérifie qu'elle existe bien avant de la supprimer
            let _ = try repository.getTask(byId: taskToDelete.id)

            // WHEN je la supprime via le service
            try service.deleteTask(byIdString: taskToDelete.id.uuidString)

            // THEN une tentative de la consulter à nouveau lève une erreur 'taskNotFound'
            #expect(throws: TaskError.taskNotFound(id: taskToDelete.id)) {
                try service.findTask(byIdString: taskToDelete.id.uuidString)
            }
        }

        @Test("Tenter plusieurs opérations sur une tâche supprimée")
        func test_operationsOnDeletedTask_failWithNotFoundError() throws {
            // GIVEN une tâche que je crée puis que je supprime immédiatement
            let task = try TaskItem(title: "Tâche éphémère")
            try repository.saveTask(task)
            let deletedTaskID = task.id
            let deletedTaskIDString = deletedTaskID.uuidString

            try service.deleteTask(byIdString: deletedTaskIDString)

            // WHEN je tente plusieurs opérations avec son ancien ID
            // THEN toutes les tentatives doivent échouer avec 'taskNotFound'
            #expect(throws: TaskError.taskNotFound(id: deletedTaskID), "La consultation doit échouer") {
                try service.findTask(byIdString: deletedTaskIDString)
            }
            #expect(throws: TaskError.taskNotFound(id: deletedTaskID), "La suppression doit échouer") {
                try service.deleteTask(byIdString: deletedTaskIDString)
            }
            #expect(throws: TaskError.taskNotFound(id: deletedTaskID), "La modification doit échouer") {
                try service.updateTask(byIdString: deletedTaskIDString, newTitle: "Titre", newDescription: "Desc")
            }
            #expect(throws: TaskError.taskNotFound(id: deletedTaskID), "Le changement de statut doit échouer") {
                try service.changeTaskStatus(byIdString: deletedTaskIDString, newStatus: .done)
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
}
