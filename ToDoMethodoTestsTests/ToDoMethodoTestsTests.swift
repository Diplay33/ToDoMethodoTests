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

@MainActor
struct MemoryTestEnvironmentFactory {
    static func create() -> (repository: MemoryRepository,service: TaskService) {
        let repository = MemoryRepository()
        let service = TaskService(repository: repository)
        return (repository, service)
    }
}

struct TaskTests {
    @MainActor
    struct TaskItemCreationTests {
        let repository: TaskRepositoryProtocol
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Création avec un titre valide")
        func test_createTask_withValidTitle_isCreatedCorrectly() throws {
            let task = try service.createTask(title: "Apprendre les tests unitaires", description: "")
            #expect(task.title == "Apprendre les tests unitaires")
            #expect(task.description.isEmpty)
            #expect(task.status == .todo)
        }

        @Test("Création avec un titre et une description valides")
        func test_createTask_withValidTitleAndDescription_isCreatedCorrectly() throws {
            let task = try service.createTask(title: "Planifier les vacances", description: "Réserver les billets d'avion et l'hôtel.")
            #expect(task.title == "Planifier les vacances")
            #expect(task.description == "Réserver les billets d'avion et l'hôtel.")
        }

        @Test("Tentative de création avec un titre vide ou blanc")
        func test_createTask_withEmptyTitle_throwsError() throws {
            #expect(throws: TaskError.titleRequired) {
                try service.createTask(title: "")
            }
            #expect(throws: TaskError.titleRequired) {
                try service.createTask(title: "   ")
            }
        }

        @Test("Tentative de création avec un titre trop long")
        func test_createTask_withOversizedTitle_throwsError() throws {
            let longTitle = String(repeating: "x", count: 101)
            #expect(throws: TaskError.titleTooLong(count: 101)) {
                try service.createTask(title: longTitle)
            }
        }

        @Test("Tentative de création avec une description trop longue")
        func test_createTask_withOversizedDescription_throwsError() throws {
            let longDescription = String(repeating: "y", count: 501)
            #expect(throws: TaskError.descriptionTooLong(count: 501)) {
                try service.createTask(title: "Titre valide", description: longDescription)
            }
        }

        @Test("Création avec un titre contenant des espaces en trop")
        func test_createTask_withSpacedTitle_trimsSpaces() throws {
            let task = try service.createTask(title: "  Nettoyer le garage  ")
            #expect(task.title == "Nettoyer le garage")
        }

        @Test("Vérification de la précision de la date de création")
        func test_taskCreationDate_isAccurate() throws {
            let beforeCreation = Date()
            let task = try service.createTask(title: "Vérifier l'heure")
            let afterCreation = Date()
            #expect(task.createdAt >= beforeCreation)
            #expect(task.createdAt <= afterCreation)
        }
    }

    @MainActor
    struct TaskItemReadTests {
        let repository: TaskRepositoryProtocol
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Consulter une tâche existante avec un ID valide")
        func test_findTask_withValidID_returnsTaskDetails() throws {
            // GIVEN une tâche existante et son ID valide sous forme de chaîne
            let existingTask = try service.createTask(title: "Tâche à retrouver", description: "Détails importants")
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
        let repository: TaskRepositoryProtocol
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Modifier le titre d'une tâche existante")
        func test_updateTask_withValidNewTitle_succeeds() throws {
            // GIVEN une tâche existante
            let originalTask = try service.createTask(title: "Titre Original", description: "Description Originale")

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
            let originalTask = try service.createTask(title: "Titre Original", description: "Description Originale")

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
            let originalTask = try service.createTask(title: "Titre Original", description: "Description Originale")

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
            let originalTask = try service.createTask(title: "Titre Original")

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
            let originalTask = try service.createTask(title: "Titre Original")
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

        @Test("Tenter de modifier une tâche avec un ID mal formaté")
        func test_updateTask_withInvalidIDFormat_throwsError() throws {
            #expect(throws: TaskError.invalidIDFormat) {
                try service.updateTask(byIdString: "invalid-id", newTitle: "Titre", newDescription: "Desc")
            }
        }
    }

    @MainActor
    struct TaskItemEditStatusTests {
        let repository: TaskRepositoryProtocol
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Changer le statut d'une tâche existante")
        func test_changeStatus_withValidStatus_succeeds() throws {
            // GIVEN une tâche existante avec le statut 'TODO'
            let originalTask = try service.createTask(title: "Ma Tâche")
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

        @Test("Tenter de changer le statut d'une tâche avec un ID mal formaté")
        func test_changeStatus_withInvalidIDFormat_throwsError() throws {
            #expect(throws: TaskError.invalidIDFormat) {
                try service.changeTaskStatus(byIdString: "invalid-id", newStatus: .done)
            }
        }
    }

    @MainActor
    struct TaskDeleteTests {
        let repository: TaskRepositoryProtocol
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Supprimer une tâche existante avec succès")
        func test_deleteExistingTask_removesItFromPersistence() throws {
            // GIVEN une tâche existante sauvegardée
            let taskToDelete = try service.createTask(title: "Tâche à supprimer")

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
            let task = try service.createTask(title: "Tâche éphémère")
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

        @Test("Tenter de supprimer une tâche avec un ID mal formaté")
        func test_deleteTask_withInvalidIDFormat_throwsError() throws {
            #expect(throws: TaskError.invalidIDFormat) {
                try service.deleteTask(byIdString: "invalid-id")
            }
        }
    }
    @MainActor
    struct TaskPaginationTests {
        let repository: MemoryRepository
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Obtenir la première page d'une liste de 25 tâches")
        func test_listTasks_fetchesFirstPageCorrectly() throws {
            // GIVEN 25 tâches dans le repository
            for i in 1...25 {
                let _ = try service.createTask(title: "Task \(i)")
            }

            // WHEN je demande la première page avec une taille de 10
            let result = try service.listTasks(page: 1, pageSize: 10)

            // THEN j'obtiens 10 tâches et les bonnes métadonnées
            #expect(result.items.count == 10, "La page doit contenir 10 éléments")
            #expect(result.metadata.currentPage == 1, "La page actuelle doit être 1")
            #expect(result.metadata.totalItems == 25, "Le nombre total d'éléments doit être 25")
            #expect(result.metadata.totalPages == 3, "Le nombre total de pages doit être 3")
        }

        @Test("Obtenir la deuxième page d'une liste")
        func test_listTasks_fetchesSecondPageCorrectly() throws {
            // GIVEN 25 tâches
            for i in 1...25 {
                let _ = try service.createTask(title: "Task \(i)")
            }

            // WHEN je demande la deuxième page avec une taille de 10
            let result = try service.listTasks(page: 2, pageSize: 10)

            // THEN j'obtiens les 10 tâches suivantes
            #expect(result.items.count == 10, "La page doit contenir 10 éléments")
            #expect(result.metadata.currentPage == 2, "La page actuelle doit être 2")
        }

        @Test("Demander une page au-delà des limites (simple list) retourne une liste vide")
        func test_listTasks_withOutOfBoundsPage_returnsEmptyList() throws {
            // GIVEN une seule tâche
            try repository.saveTask(try TaskItem(title: "Une Tâche"))

            // WHEN je demande la deuxième page (qui n'existe pas)
            // This call will trigger the guard condition you mentioned.
            let result = try service.listTasks(page: 2, pageSize: 10)

            // THEN j'obtiens une liste vide mais les bonnes métadonnées
            #expect(result.items.isEmpty, "La liste d'items doit être vide")
            #expect(result.metadata.currentPage == 2, "La page demandée reste 2")
            #expect(result.metadata.totalItems == 1, "Le total reste 1")
            #expect(result.metadata.totalPages == 1, "Le nombre de pages reste 1")
        }

        @Test("Demander une page au-delà des limites (complex list) retourne une liste vide")
        func test_complexListTasks_withOutOfBoundsPage_returnsEmptyList() throws {
            // GIVEN 3 tâches avec le même statut
            _ = try service.createTask(title: "Task 1") // status = .todo
            _ = try service.createTask(title: "Task 2") // status = .todo
            _ = try service.createTask(title: "Task 3") // status = .todo

            // WHEN je demande la deuxième page (qui n'existe pas) en utilisant un filtre.
            // Il y a 3 items au total, donc avec un pageSize de 5, il n'y a qu'une seule page.
            let result = try service.listTasks(filterByStatus: .todo, page: 2, pageSize: 5)

            // THEN j'obtiens une liste vide mais les bonnes métadonnées
            #expect(result.items.isEmpty, "La liste d'items doit être vide")
            #expect(result.metadata.currentPage == 2, "La page demandée reste 2")
            #expect(result.metadata.totalItems == 3, "Le total des items filtrés doit être 3")
            #expect(result.metadata.totalPages == 1, "Le nombre de pages doit être 1")
        }

        @Test("Demander la liste avec les paramètres par défaut")
        func test_listTasks_withDefaultParameters_returnsFirstPageOf20() throws {
            // GIVEN 25 tâches
            for i in 1...25 {
                let _ = try service.createTask(title: "Task \(i)")
            }

            // WHEN je demande la liste sans spécifier de paramètres
            let result = try service.listTasks()

            // THEN j'obtiens la première page avec une taille par défaut de 20
            #expect(result.items.count == 20, "La page doit contenir 20 éléments par défaut")
            #expect(result.metadata.pageSize == 20, "La taille de page doit être 20")
            #expect(result.metadata.currentPage == 1, "La page doit être 1")
        }

        @Test("Demander la liste avec une taille de page invalide lève une erreur")
        func test_listTasks_withInvalidPageSize_throwsError() throws {
            // WHEN je spécifie une taille de page de zéro ou négative
            // THEN j'obtiens une erreur `invalidPageParameters`
            #expect(throws: TaskError.invalidPageParameters) {
                try service.listTasks(pageSize: 0)
            }
            #expect(throws: TaskError.invalidPageParameters) {
                try service.listTasks(pageSize: -1)
            }
            #expect(throws: TaskError.invalidPageParameters) {
                try service.listTasks(page: 0)
            }
        }

        @Test("Demander la liste complexe avec des paramètres de page invalides lève une erreur")
        func test_complexListTasks_withInvalidPageParams_throwsError() throws {
            #expect(throws: TaskError.invalidPageParameters) {
                try service.listTasks(sortBy: .byCreationDate(order: .ascending), page: 0)
            }
            #expect(throws: TaskError.invalidPageParameters) {
                try service.listTasks(sortBy: .byCreationDate(order: .ascending), pageSize: -1)
            }
        }

        @Test("Demander la liste quand il n'y a aucune tâche")
        func test_listTasks_whenEmpty_returnsEmptyResult() throws {
            // GIVEN un repository vide (il est vide par défaut à l'initialisation du test)

            // WHEN je demande la liste
            let result = try service.listTasks()

            // THEN j'obtiens un résultat vide avec des métadonnées à zéro
            #expect(result.items.isEmpty, "La liste d'items doit être vide")
            #expect(result.metadata.totalItems == 0, "Le nombre total d'éléments doit être 0")
            #expect(result.metadata.totalPages == 0, "Le nombre total de pages doit être 0")
        }
    }

    @MainActor
    struct TaskSearchTests {
        let repository: MemoryRepository
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()

            // GIVEN un jeu de données de test créé une seule fois pour tous les tests de cette suite
            let _ = try! service.createTask(title: "Projet Apple", description: "Développer une nouvelle app")
            let _ = try! service.createTask(title: "Faire les courses", description: "Acheter des pommes")
            let _ = try! service.createTask(title: "Réunion importante", description: "Discuter du projet Alpha")
            let _ = try! service.createTask(title: "Sport", description: "Ne pas oublier la pomme post-entraînement")
        }

        @Test("Rechercher un terme dans le titre ou la description")
        func test_search_byKeyword_returnsMatchingTasks() throws {
            // WHEN je recherche "Projet" (qui est dans un titre et une description)
            let result = try service.listTasks(searchTerm: "Projet")
            // THEN j'obtiens les 2 tâches correspondantes
            #expect(result.items.count == 2)
        }

        @Test("La recherche est insensible à la casse")
        func test_search_isCaseInsensitive() throws {
            // WHEN je recherche "alpha" en minuscule
            let result = try service.listTasks(searchTerm: "alpha")
            // THEN la tâche contenant "Alpha" est bien trouvée
            #expect(result.items.count == 1)
            #expect(result.items.first?.title == "Réunion importante")
        }

        @Test("La recherche sur un terme inexistant retourne une liste vide")
        func test_search_withNonExistentTerm_returnsEmpty() throws {
            let result = try service.listTasks(searchTerm: "banane")
            #expect(result.items.isEmpty)
        }

        @Test("La recherche avec une chaîne vide retourne toutes les tâches")
        func test_search_withEmptyTerm_returnsAllTasks() throws {
            let result = try service.listTasks(searchTerm: "")
            #expect(result.items.count == 4)
        }

        @Test("Les résultats de recherche sont bien paginés")
        func test_search_resultsArePaginated() throws {
            // GIVEN nos 4 tâches de base, dont 3 contiennent "p" (Projet, app, pommes, importante, Sport, post)
            let result = try service.listTasks(searchTerm: "p", pageSize: 2)

            // THEN j'obtiens 2 tâches et les bonnes informations de pagination
            #expect(result.items.count == 2, "La page doit contenir 2 éléments")
            #expect(result.metadata.totalItems == 4, "Il y a 4 résultats au total")
            #expect(result.metadata.totalPages == 2, "4 items / 2 par page = 2 pages")
            #expect(result.metadata.currentPage == 1)
        }
    }
    @MainActor
    struct TaskFilterTests {
        let repository: MemoryRepository
        let service: TaskService
        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()

            // GIVEN un jeu de données avec différents statuts
            _ = try! service.createTask(title: "Faire les courses")
            var task2 = try! service.createTask(title: "Répondre aux emails")
            var task3 = try! service.createTask(title: "Commencer le projet X")

            // Changer les statuts pour les tests
            task2.status = .inProgress
            task3.status = .done
            try! repository.saveTask(task2)
            try! repository.saveTask(task3)
        }
        @Test("Filtrer par un statut existant retourne les bonnes tâches")
        func test_filterByStatus_returnsMatchingTasks() throws {
            // WHEN je filtre par 'TODO'
            var result = try service.listTasks(filterByStatus: .todo)
            // THEN j'obtiens une seule tâche
            #expect(result.items.count == 1)
            #expect(result.items.first?.title == "Faire les courses")

            // WHEN je filtre par 'ONGOING'
            result = try service.listTasks(filterByStatus: .inProgress)
            #expect(result.items.count == 1)
            #expect(result.items.first?.title == "Répondre aux emails")

            // WHEN je filtre par un statut qui n'a aucune tâche
            repository.clear()
            let _ = try! service.createTask(title: "Une seule tâche TODO")
            result = try service.listTasks(filterByStatus: .done)
            // THEN j'obtiens une liste vide
            #expect(result.items.isEmpty)
            #expect(result.metadata.totalItems == 0)
        }

        @Test("Les résultats filtrés sont paginés")
        func test_filteredResults_arePaginated() throws {
            // GIVEN 7 tâches 'TODO' et 5 autres
            repository.clear()
            for i in 1...7 {
                let _ = try service.createTask(title: "TODO Task \(i)")
            }
            for i in 1...5 {
                var task = try service.createTask(title: "Other Task \(i)")
                task.status = .done
                try repository.saveTask(task)
            }

            // WHEN je filtre par 'TODO' avec une taille de page de 5
            let result = try service.listTasks(filterByStatus: .todo, pageSize: 5)

            // THEN j'obtiens 5 tâches et les bonnes métadonnées
            #expect(result.items.count == 5)
            #expect(result.metadata.currentPage == 1)
            #expect(result.metadata.totalItems == 7, "Le total doit refléter le nombre d'items filtrés")
            #expect(result.metadata.totalPages == 2, "7 items / 5 par page = 2 pages")
        }
    }

    @MainActor
    struct TaskSortTests {
        let repository: MemoryRepository
        let service: TaskService
        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()

            // GIVEN un jeu de données avec différents statuts
            _ = try! service.createTask(title: "Faire les courses")
            var task2 = try! service.createTask(title: "Répondre aux emails")
            var task3 = try! service.createTask(title: "Commencer le projet X")

            // Changer les statuts pour les tests
            task2.status = .inProgress
            task3.status = .done
            try! repository.saveTask(task2)
            try! repository.saveTask(task3)
        }

        @Test("Trier les tâches par date de création")
        func test_listTasks_sortByCreationDate() async throws {
            repository.clear()
            // GIVEN plusieurs tâches créées à des moments différents
            let task1 = try service.createTask(title: "Ancienne tâche")
            try await Task.sleep(for: .milliseconds(10))
            let task2 = try service.createTask(title: "Nouvelle tâche")

            // WHEN je trie par date ascendante
            var result = try service.listTasks(sortBy: .byCreationDate(order: .ascending))
            // THEN la plus ancienne apparaît en premier
            #expect(result.items.first?.id == task1.id)

            // WHEN je trie par date descendante
            result = try service.listTasks(sortBy: .byCreationDate(order: .descending))
            // THEN la plus récente apparaît en premier
            #expect(result.items.first?.id == task2.id)
        }

        @Test("Trier les tâches par titre")
        func test_listTasks_sortByTitle() throws {
            repository.clear()
            // GIVEN des tâches avec des titres variés
            _ = try service.createTask(title: "Tâche B")
            _ = try service.createTask(title: "Tâche A")
            _ = try service.createTask(title: "Tâche C")

            // WHEN je trie par titre ascendant
            var result = try service.listTasks(sortBy: .byTitle(order: .ascending))
            // THEN les tâches sont dans l'ordre alphabétique
            #expect(result.items.map(\.title) == ["Tâche A", "Tâche B", "Tâche C"])

            // WHEN je trie par titre descendant
            result = try service.listTasks(sortBy: .byTitle(order: .descending))
            // THEN les tâches sont dans l'ordre alphabétique inverse
            #expect(result.items.map(\.title) == ["Tâche C", "Tâche B", "Tâche A"])
        }

        @Test("Trier les tâches par statut")
        func test_listTasks_sortByStatus() throws {
            repository.clear()
            // GIVEN des tâches avec des statuts variés
            var taskA = try service.createTask(title: "Tâche A (Done)")
            var taskB = try service.createTask(title: "Tâche B (Todo)")
            var taskC = try service.createTask(title: "Tâche C (In Progress)")

            taskA.status = .done
            taskB.status = .todo // Already todo, but explicit
            taskC.status = .inProgress

            try repository.saveTask(taskA)
            try repository.saveTask(taskB)
            try repository.saveTask(taskC)

            // WHEN je trie par statut
            let result = try service.listTasks(sortBy: .byStatus)
            // THEN les tâches sont groupées par statut (TODO -> ONGOING -> DONE)
            #expect(result.items.map(\.status) == [.todo, .inProgress, .done])
        }

        @Test("Le tri par défaut et la combinaison avec les filtres fonctionnent")
        func test_defaultSort_and_sortWithFilter() async throws {
            repository.clear()
            // GIVEN plusieurs tâches
            let taskA = try service.createTask(title: "AAA")
            try await Task.sleep(for: .milliseconds(10))
            let taskZ = try service.createTask(title: "ZZZ")
            var taskA_done = taskA; taskA_done.status = .done
            try repository.saveTask(taskA_done)

            // WHEN je ne spécifie pas de tri (Test 6)
            var result = try service.listTasks()
            // THEN le tri par défaut est par date descendante
            #expect(result.items.first?.id == taskZ.id)

            // WHEN je filtre par statut 'DONE' et trie par titre ascendant (Test 8)
            result = try service.listTasks(sortBy: .byTitle(order: .ascending), filterByStatus: .done)
            // THEN j'obtiens une seule tâche (celle filtrée)
            #expect(result.items.count == 1)
            #expect(result.items.first?.id == taskA.id)
        }
    }

    // MARK: - Integration Tests for SwiftData Repository

    @MainActor
    struct SwiftDataRepositoryIntegrationTests {

        let container: ModelContainer
        let repository: SwiftDataToDoRepository

        init() {
            // This setup creates a fresh in-memory database for each test run.
            let schema = Schema([Item.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try! ModelContainer(for: schema, configurations: [configuration])
            repository = SwiftDataToDoRepository(context: container.mainContext)
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
            // GIVEN an original task saved to the repo
            let originalTask = try TaskItem(title: "Original Title")
            try repository.saveTask(originalTask)

            // WHEN we modify it and save it again
            var modifiedTask = originalTask
            modifiedTask.title = "Updated Title"
            try repository.saveTask(modifiedTask)

            // THEN the retrieved task has the updated title
            let retrievedTask = try repository.getTask(byId: originalTask.id)
            #expect(retrievedTask.title == "Updated Title")

            // AND there is still only one item in the database
            let idToFind = originalTask.id
            let predicate = #Predicate<Item> { $0.id == idToFind }
            let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate)
            let count = try container.mainContext.fetchCount(fetchDescriptor)
            #expect(count == 1)
        }

        @Test("Delete an existing task removes it from the context")
        func test_deleteTask_removesIt() throws {
            // GIVEN a saved task
            let task = try TaskItem(title: "Task to Delete")
            try repository.saveTask(task)

            // Check it exists
            let _ = try repository.getTask(byId: task.id)

            // WHEN it's deleted
            try repository.deleteTask(byId: task.id)

            // THEN getting it again throws an error
            #expect(throws: TaskError.taskNotFound(id: task.id)) {
                try repository.getTask(byId: task.id)
            }
        }

        @Test("Attempting to delete a non-existent task throws an error")
        func test_deleteNonExistentTask_throwsNotFoundError() throws {
            let nonExistentID = UUID()
            #expect(throws: TaskError.taskNotFound(id: nonExistentID)) {
                try repository.deleteTask(byId: nonExistentID)
            }
        }

        @Test("List tasks with simple pagination works correctly")
        func test_listTasks_simplePagination() throws {
            // GIVEN 15 tasks
            for i in 1...15 {
                try repository.saveTask(try TaskItem(title: "Task \(i)"))
            }

            // WHEN fetching the second page
            let result = try repository.listTasks(page: 2, pageSize: 5)

            // THEN the result is correct
            #expect(result.items.count == 5)
            #expect(result.metadata.currentPage == 2)
            #expect(result.metadata.totalItems == 15)
            #expect(result.metadata.totalPages == 3)
        }

        @Test("List tasks with complex sorting, filtering, and searching")
        func test_listTasks_complexQueries() throws {
            // GIVEN a diverse set of tasks
            var taskA = try TaskItem(title: "Apple Project", description: "Work on Swift app")
            var taskB = try TaskItem(title: "Banana Recipe", description: "Find a good one")
            var taskC = try TaskItem(title: "Car Wash", description: "Clean the blue car")
            var taskD = try TaskItem(title: "Dog Walk", description: "Walk the apple-headed chihuahua")

            taskA.createdAt = Date().addingTimeInterval(-400)
            taskB.createdAt = Date().addingTimeInterval(-300)
            taskC.createdAt = Date().addingTimeInterval(-200)
            taskD.createdAt = Date().addingTimeInterval(-100)

            taskB.status = .inProgress
            taskD.status = .done

            try repository.saveTask(taskA)
            try repository.saveTask(taskB)
            try repository.saveTask(taskC)
            try repository.saveTask(taskD)

            // Test 1: Filter by status
            var result = try repository.listTasks(sortBy: .byCreationDate(order: .descending), filterByStatus: .inProgress, searchTerm: nil, page: 1, pageSize: 10)
            #expect(result.items.count == 1)
            #expect(result.items.first?.title == "Banana Recipe")

            // Test 2: Search by term
            result = try repository.listTasks(sortBy: .byCreationDate(order: .descending), filterByStatus: nil, searchTerm: "apple", page: 1, pageSize: 10)
            #expect(result.items.count == 2)
            #expect(result.items.map(\.title).contains("Apple Project"))
            #expect(result.items.map(\.title).contains("Dog Walk"))

            // Test 3: Filter and search
            result = try repository.listTasks(sortBy: .byCreationDate(order: .descending), filterByStatus: .todo, searchTerm: "car", page: 1, pageSize: 10)
            #expect(result.items.count == 1)
            #expect(result.items.first?.title == "Car Wash")

            // Test 4: Sort by title ascending
            result = try repository.listTasks(sortBy: .byTitle(order: .ascending), filterByStatus: nil, searchTerm: nil, page: 1, pageSize: 10)
            #expect(result.items.map(\.title) == ["Apple Project", "Banana Recipe", "Car Wash", "Dog Walk"])

            // Test 5: Sort by status
            result = try repository.listTasks(sortBy: .byStatus, filterByStatus: nil, searchTerm: nil, page: 1, pageSize: 10)
            #expect(result.items.map(\.status) == [.todo, .todo, .inProgress, .done])

            // Test 6: Empty result from filtering
            let emptyResult = try repository.listTasks(sortBy: .byCreationDate(order: .descending), filterByStatus: .done, searchTerm: "nonexistent", page: 1, pageSize: 10)
            #expect(emptyResult.items.isEmpty)
            #expect(emptyResult.metadata.totalItems == 0)
        }
    }

    @MainActor
    struct TaskDueDateTests {
        let repository: MemoryRepository
        let service: TaskService

        init() {
            (repository, service) = MemoryTestEnvironmentFactory.create()
        }

        @Test("Définir une date d'échéance future valide")
        func test_setValidFutureDueDate() throws {
            // GIVEN j'ai une tâche existante
            let task = try service.createTask(title: "Planifier le futur")
            let futureDate = Date().addingTimeInterval(86400)

            // WHEN je définis une date d'échéance future valide
            let updatedTask = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: futureDate)

            // THEN la date est enregistrée et visible dans les détails
            #expect(updatedTask.dueDate == futureDate)
            let persistedTask = try service.findTask(byIdString: task.id.uuidString)
            #expect(persistedTask.dueDate == futureDate)
        }

        @Test("Modifier une date d'échéance existante")
        func test_modifyExistingDueDate() throws {
            // GIVEN j'ai une tâche avec une échéance
            var task = try service.createTask(title: "Changer d'avis")
            let oldDate = Date().addingTimeInterval(86400)
            task = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: oldDate)
            #expect(task.dueDate == oldDate)

            let newDate = Date().addingTimeInterval(172800)

            // WHEN je modifie la date d'échéance
            let updatedTask = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: newDate)

            // THEN la nouvelle date remplace l'ancienne
            #expect(updatedTask.dueDate == newDate)
        }

        @Test("Supprimer une date d'échéance")
        func test_removeDueDate() throws {
            // GIVEN j'ai une tâche avec une échéance
            var task = try service.createTask(title: "Plus de pression")
            let dueDate = Date()
            task = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: dueDate)
            #expect(task.dueDate != nil)

            // WHEN je supprime la date d'échéance (la définir à null)
            let updatedTask = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: nil)

            // THEN la tâche n'a plus d'échéance
            #expect(updatedTask.dueDate == nil)
        }

        @Test("Définir une date d'échéance dans le passé")
        func test_setPastDueDate() throws {
            // GIVEN j'ai une tâche existante
            let task = try service.createTask(title: "Voyage dans le temps")
            let pastDate = Date().addingTimeInterval(-86400)

            // WHEN je tente de définir une date d'échéance dans le passé
            // THEN un avertissement est généré (implicite) mais la date est acceptée
            let updatedTask = try service.setTaskDueDate(byIdString: task.id.uuidString, newDueDate: pastDate)
            #expect(updatedTask.dueDate == pastDate)
        }

        @Test("Tenter de définir une échéance sur une tâche inexistante")
        func test_setDueDateOnNonexistentTask() throws {
            // GIVEN un ID invalide
            let invalidID = UUID()

            // WHEN j'utilise cet ID pour définir une échéance
            // THEN j'obtiens une erreur "Task not found"
            #expect(throws: TaskError.taskNotFound(id: invalidID)) {
                try service.setTaskDueDate(byIdString: invalidID.uuidString, newDueDate: Date())
            }
        }

        @Test("Tenter de définir une échéance avec un ID mal formaté")
        func test_setDueDate_withInvalidIDFormat_throwsError() throws {
            // GIVEN un ID mal formaté
            let invalidIDString = "ceci-n-est-pas-un-uuid"

            // WHEN je tente de définir une échéance avec cet ID
            // THEN j'obtiens une erreur 'invalidIDFormat'
            #expect(throws: TaskError.invalidIDFormat) {
                try service.setTaskDueDate(byIdString: invalidIDString, newDueDate: Date())
            }
        }
    }
}
