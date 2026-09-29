//
//  Habit_ManagerUITests.swift
//  Habit ManagerUITests
//
//  Created by Agustin Russo on 23/09/2025.
//

import XCTest

final class Habit_ManagerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateAndCompleteHabitCriticalFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let todosTab = app.tabBars.buttons["Todos"].exists ? app.tabBars.buttons["Todos"] : app.buttons["Todos"]
        XCTAssertTrue(todosTab.waitForExistence(timeout: 5), "The 'Todos' tab should exist in the tab bar")
        todosTab.tap()

        let addButton = app.buttons["add_habit_button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "The '+' add habit button should exist")
        addButton.tap()

        let habitName = "Meditar 10 minutos"
        let nameField = app.textFields["habit_name_textfield"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "The habit name text field should exist in the modal")
        nameField.tap()
        nameField.typeText(habitName)

        let saveButton = app.buttons["save_habit_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "The 'Guardar' button should exist")
        XCTAssertTrue(saveButton.isEnabled, "The 'Guardar' button should be enabled after entering a habit name")
        saveButton.tap()

        let habitInList = app.staticTexts[habitName]
        XCTAssertTrue(habitInList.waitForExistence(timeout: 5), "The new habit '\(habitName)' should appear in the 'Todos' list")

        let hoyTab = app.tabBars.buttons["Hoy"].exists ? app.tabBars.buttons["Hoy"] : app.buttons["Hoy"]
        XCTAssertTrue(hoyTab.waitForExistence(timeout: 5), "The 'Hoy' tab should exist in the tab bar")
        hoyTab.tap()

        let habitInToday = app.staticTexts[habitName]
        XCTAssertTrue(habitInToday.waitForExistence(timeout: 5), "The habit '\(habitName)' should appear in today's scheduled list")

        let toggleButton = app.buttons["habit_completion_toggle_\(habitName)"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5), "The completion toggle button for '\(habitName)' should exist")
        toggleButton.tap()

        let completedPredicate = NSPredicate(format: "value == 'completed'")
        let completionExpectation = XCTNSPredicateExpectation(predicate: completedPredicate, object: toggleButton)
        let waitResult = XCTWaiter().wait(for: [completionExpectation], timeout: 5)
        XCTAssertEqual(waitResult, .completed, "The toggle button value should change to 'completed'")

        let logrosTab = app.tabBars.buttons["Logros"].exists ? app.tabBars.buttons["Logros"] : app.buttons["Logros"]
        XCTAssertTrue(logrosTab.waitForExistence(timeout: 5), "The 'Logros' tab should exist in the tab bar")
        logrosTab.tap()

        let userLevelCard = app.otherElements["user_level_card"]
        let badgesGrid = app.otherElements["badges_grid_section"]
        let userLevelText = app.staticTexts["user_level_text"]

        let isLevelOrBadgesVisible = userLevelCard.waitForExistence(timeout: 5) ||
                                     badgesGrid.waitForExistence(timeout: 5) ||
                                     userLevelText.waitForExistence(timeout: 5)
        XCTAssertTrue(isLevelOrBadgesVisible, "The user level card or badges grid should be visible in 'Logros' tab")
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
