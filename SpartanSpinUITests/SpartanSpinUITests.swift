//
//  SpartanSpinUIInteractionTests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import XCTest

final class SpartanSpinUIInteractionTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
    func testEditingGoals() {
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("New Goal")
        app.textFields["Amount"].tap()
        app.typeText("1")
        app.buttons["Save"].tap()
        
        app.buttons["New Goal"].tap()
        
        XCTAssertTrue(app.staticTexts["Goal Title Toolbar"].exists,
            "Goal Title Toolbar Exists"
        )

        app.buttons["Edit Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Edited ")
        app.textFields["Amount"].tap()
        app.typeText("1")
        app.buttons["Unit Picker"].tap()
        app.buttons["Repitition"].tap()
        app.buttons["Save"].tap()

        XCTAssertTrue(
            app.staticTexts["Repititions"].exists,
            "Now that repititions is the unit, it shouls state such below the tasks needed and completed."
        )
        XCTAssertEqual(
            app.staticTexts["Goal Title Toolbar"].label, "Edited New Goal",
            "Static text 'Edited New Goal' exists meaning the goal title has been successfully edited."
        )
        XCTAssert(
            app.staticTexts["/11"].exists,
            "Static text '/11' exists meaning the goal tasks needed successfully was edited to be 11."
        )
        
        app.buttons["Edit Goal"].tap()
        app.textFields["Amount"].tap()
        app.textFields["Amount"].press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        app.typeText("1")
        
        XCTAssertTrue(app.staticTexts["Repitition"].exists, "Repitition should now be singular.")
    }
    
    func testCompletingAndUndoingTasks() {
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("New Goal")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        
        app.buttons["New Goal"].tap()
        
        app.buttons["Complete Task"].tap()
        
        XCTAssertTrue(app.buttons["1"].exists,
            "Tasks completed is 1."
        )
        
        app.buttons["Undo Task"].tap()
        
        XCTAssertTrue(app.buttons["0"].exists,
            "Tasks completed is 0."
        )
        
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()

        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is now a 1 day streak."
        )
        
        app.buttons["Undo Task"].tap()
        
        XCTAssertFalse(app.staticTexts["1 Day Streak"].exists, "There is no longer a 1 day streak.")
    }
    
    func testCompletingTasksViaTextField() {
        app.buttons["Add Sample Goals"].tap()
        app.buttons["Walk Dog"].tap()
        app.buttons["0"].tap()
        
        XCTAssertTrue(app.buttons["OK"].exists,
            "There is an OK button."
        )
        XCTAssertTrue(app.buttons["Cancel"].exists,
            "There is a Cancel button."
        )
        
        app.typeText("2")
        app.buttons["OK"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is now a 1 day streak."
        )
        
        app.buttons["2"].tap()
        app.typeText("2")
        app.buttons["OK"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is still only a 1 day streak."
        )
        
        app.buttons["2"].tap()
        app.typeText("3")
        app.buttons["OK"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is still only a 1 day streak."
        )
        
        app.buttons["3"].tap()
        app.typeText("1")
        app.buttons["OK"].tap()
        
        XCTAssertFalse(app.staticTexts["1 Day Streak"].exists,
            "There is now no streak."
        )
        
        app.buttons["1"].tap()
        app.typeText("3")
        app.buttons["OK"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is now a 1 day streak."
        )
    }
    
    func testCompletingTasksAndEditingTasksNeeded() {
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("New Goal")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        app.buttons["New Goal"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is now a 1 day streak."
        )
        
        app.buttons["Edit Goal"].tap()
        app.textFields["Amount"].tap()
        app.typeText("1")
        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is still only a 1 day streak. Updating the amount needed does not make the streak decrease."
        )
        
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        app.buttons["Complete Task"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is still a 1 day streak. The streak can only increase 1 time per period."
        )
        
        app.buttons["Edit Goal"].tap()
        app.textFields["Amount"].tap()
        app.textFields["Amount"].press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        app.typeText("1")
        
        XCTAssertTrue(app.staticTexts["1 Day Streak"].exists,
            "There is still a 1 day streak. The streak can only increase 1 time per period."
        )
    }
    
    func testChangingTimeline() {
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("New Goal")
        app.textFields["Amount"].tap()
        app.typeText("1")
        app.buttons["Save"].tap()
        
        app.buttons["New Goal"].tap()
        
        app.buttons["Complete Task"].tap()
        
        app.buttons["Edit Goal"].tap()
        app.buttons["Timeline Picker"].tap()
        app.buttons["Weekly"].tap()
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Week Streak"].exists,
            "There is now a 1 week streak."
        )
        
        app.buttons["Edit Goal"].tap()
        app.buttons["Timeline Picker"].tap()
        app.buttons["Monthly"].tap()
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.staticTexts["1 Month Streak"].exists,
            "There is now a 1 month streak."
        )
    }
    
    func testSwipeToDelete() {
        app.buttons["Add Sample Goals"].tap()
        let goalToDelete = "Brush Teeth"
        let goalCell = app.cells.containing(.staticText, identifier: goalToDelete).firstMatch
        XCTAssertTrue(goalCell.exists, "Goal cell should exist")
        
        goalCell.swipeLeft()
        
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists, "Delete button should appear after swipe.")
        
        deleteButton.tap()
        
        XCTAssertFalse(goalCell.exists, "Goal cell should exist")
    }
}
