//
//  Habit_ManagerUITests.swift
//  Habit ManagerUITests
//
//  Created by Agustin Russo on 23/09/2025.
//

import XCTest

final class Habit_ManagerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testCreateAndCompleteHabitCriticalFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        // 1. Navigates to the 'Todos' tab
        let todosTab = app.tabBars.buttons["Todos"].exists ? app.tabBars.buttons["Todos"] : app.buttons["Todos"]
        XCTAssertTrue(todosTab.waitForExistence(timeout: 5), "The 'Todos' tab should exist in the tab bar")
        todosTab.tap()

        // 2. Taps the '+' button to open the add habit modal
        let addButton = app.buttons["add_habit_button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "The '+' add habit button should exist")
        addButton.tap()

        // 3. Enters a new habit name (e.g. 'Meditar 10 minutos')
        let habitName = "Meditar 10 minutos"
        let nameField = app.textFields["habit_name_textfield"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "The habit name text field should exist in the modal")
        nameField.tap()
        nameField.typeText(habitName)

        // 4. Taps 'Guardar'
        let saveButton = app.buttons["save_habit_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "The 'Guardar' button should exist")
        XCTAssertTrue(saveButton.isEnabled, "The 'Guardar' button should be enabled after entering a habit name")
        saveButton.tap()

        // 5. Asserts the new habit appears in the list
        let habitInList = app.staticTexts[habitName]
        XCTAssertTrue(habitInList.waitForExistence(timeout: 5), "The new habit '\(habitName)' should appear in the 'Todos' list")

        // 6. Switches to the 'Hoy' tab
        let hoyTab = app.tabBars.buttons["Hoy"].exists ? app.tabBars.buttons["Hoy"] : app.buttons["Hoy"]
        XCTAssertTrue(hoyTab.waitForExistence(timeout: 5), "The 'Hoy' tab should exist in the tab bar")
        hoyTab.tap()

        // 7. Asserts the habit appears in today's scheduled list
        let habitInToday = app.staticTexts[habitName]
        XCTAssertTrue(habitInToday.waitForExistence(timeout: 5), "The habit '\(habitName)' should appear in today's scheduled list")

        // 8. Taps the habit's toggle/completion button to mark it completed
        let toggleButton = app.buttons["habit_completion_toggle_\(habitName)"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5), "The completion toggle button for '\(habitName)' should exist")
        toggleButton.tap()

        // Verify completion state updated
        let completedPredicate = NSPredicate(format: "value == 'completed'")
        let completionExpectation = XCTNSPredicateExpectation(predicate: completedPredicate, object: toggleButton)
        let waitResult = XCTWaiter().wait(for: [completionExpectation], timeout: 5)
        XCTAssertEqual(waitResult, .completed, "The toggle button value should change to 'completed'")

        // 9. Switches to the 'Logros' tab and asserts the user level / badges view is visible
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
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
