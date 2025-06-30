//
//  ToDoMethodoTestsTests.swift
//  ToDoMethodoTestsTests
//
//  Created by Jacques HU on 30/06/2025.
//

import Testing
@testable import ToDoMethodoTests // Import your app module to access its types
import Foundation

struct ToDoMethodoTestsTests {

    @Test("US1: Create task with valid title")
    func test_createTask_withValidTitle_isCreatedCorrectly() throws {
        // GIVEN a valid title
        let title = "My first task"
        let creationTime = Date()

        // WHEN I create a task
        let task = try TaskItem(title: title, creationDate: creationTime)

        // THEN it is created with a unique ID, the provided title,
        // an empty description, the creation date, and a 'TODO' status.
        #expect(task.title == title, "Title should match the provided one.")
        #expect(task.description.isEmpty, "Description should be empty by default.")
        #expect(task.status == .todo, "Status should be 'TODO' by default.")

        let timeDifference = abs(task.createdAt.timeIntervalSince(creationTime))
        #expect(timeDifference < 1, "Creation date should be accurate to the second.")
    }

    @Test("US2: Create task with valid title and description")
    func test_createTask_withValidTitleAndDescription_isCreatedCorrectly() throws {
        // GIVEN a valid title and description
        let title = "A task with description"
        let description = "This is a detailed description."

        // WHEN I create a task
        let task = try TaskItem(title: title, description: description)

        // THEN it is created with the provided title and description
        #expect(task.title == title)
        #expect(task.description == description)
    }

    @Test("US3: Attempt to create task with empty or whitespace title")
    func test_createTask_withEmptyTitle_throwsError() throws {
        // GIVEN an empty title
        // WHEN I attempt to create a task
        // THEN I get a 'Title is required' error
        #expect(throws: TaskValidationError.titleRequired) {
            try TaskItem(title: "")
        }

        // GIVEN a title with only spaces
        // WHEN I attempt to create a task
        // THEN I get a 'Title is required' error
        #expect(throws: TaskValidationError.titleRequired) {
            try TaskItem(title: "   ")
        }
    }

    @Test("US4: Attempt to create task with oversized title")
    func test_createTask_withOversizedTitle_throwsError() throws {
        // GIVEN a title with more than 100 characters
        let longTitle = String(repeating: "A", count: 101)

        // WHEN I attempt to create a task
        // THEN I get a 'Title cannot exceed 100 characters' error
        #expect(throws: TaskValidationError.titleTooLong(count: 101)) {
            try TaskItem(title: longTitle)
        }
    }

    @Test("US5: Attempt to create task with oversized description")
    func test_createTask_withOversizedDescription_throwsError() throws {
        // GIVEN a description with more than 500 characters
        let longDescription = String(repeating: "B", count: 501)

        // WHEN I attempt to create a task
        // THEN I get a 'Description cannot exceed 500 characters' error
        #expect(throws: TaskValidationError.descriptionTooLong(count: 501)) {
            try TaskItem(title: "Valid Title", description: longDescription)
        }
    }

    @Test("US6: Create task with title containing leading/trailing spaces")
    func test_createTask_withSpacedTitle_trimsSpaces() throws {
        // GIVEN a title with leading and trailing spaces
        let spacedTitle = "  A valid title with spaces  "

        // WHEN I create a task
        let task = try TaskItem(title: spacedTitle)

        // THEN the task is created with the title trimmed
        #expect(task.title == "A valid title with spaces")
    }

    @Test("US7: Newly created task has an accurate creation date")
    func test_taskCreationDate_isAccurate() throws {
        // GIVEN I am about to create a task
        let beforeCreation = Date()

        // WHEN I create the task
        let task = try TaskItem(title: "A task to check date")
        let afterCreation = Date()

        // THEN its creation date is between the moments before and after creation
        #expect(task.createdAt >= beforeCreation)
        #expect(task.createdAt <= afterCreation)
    }
}
