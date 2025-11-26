//
//  SpartanSpinUITests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import XCTest

final class SpartanSpinUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
    func testNoGoalsAtStart() {
        XCTAssertTrue(
            app.staticTexts["Create a new goal!"].exists,
            "Static text saying 'Create a new goal!' exists, meaning no goals have been created yet."
        )
    }
    
//    func testForButtons() {
//        XCTAssertTrue(app.buttons["Add Goal"].exists, "There should be an Add Goal button.")
//        XCTAssertTrue(app.buttons["Add Sample Goals"].exists, "There should be an Add Sample Goals debug button.")
//        
//        app.buttons["Add Sample Goals"].tap()
//        
//        XCTAssertTrue(app.navigationBars.buttons["Add Goal"].exists, "There should be an Add Samples toolbar button.")
//        XCTAssertTrue(
//            app.navigationBars.buttons["ADD SAMPLES"].exists,
//            "There should be an ADD SAMPLES debug toolbar button."
//        )
//        XCTAssertTrue(
//            app.navigationBars.buttons["DELETE SAMPLES"].exists,
//            "There should be an DELETE SAMPLES toolbar debug button."
//        )
//        
//        app.buttons["Add Goal"].tap()
//        
//        XCTAssertTrue(app.textFields["Title TextField"].exists, "There should be a title text field.")
//        XCTAssertTrue(app.textFields["Amount TextField"].exists, "There should be an amount text field.")
//        XCTAssertTrue(
//            app.buttons["Unit Picker"].exists,
//            "There should be a unit picker."
//        )
//        XCTAssertTrue(
//            app.buttons["Timeline Picker"].exists,
//            "There should be a timeline picker."
//        )
//        XCTAssertTrue(
//            app.navigationBars.buttons["Save"].exists,
//            "There should be a save toolbar button."
//        )
//        XCTAssertTrue(
//            app.toggles["Reminders Toggle"].exists,
//            "There should be a reminders toggle."
//        )
//        
//        app.buttons["Save"].tap()
//        
//        app.buttons["Feed Dog"].tap()
//        
//        XCTAssertTrue(app.navigationBars.buttons["Edit Goal"].exists, "There should be a Edit Goal toolbar button.")
//        XCTAssertTrue(
//    app.navigationBars.buttons["Delete Goal"].exists,
//    "There should be a Delete Goal toolbar button."
//    )
//        XCTAssertTrue(app.buttons["Complete Task"].exists, "There should be a Complete Task button.")
//        XCTAssertTrue(app.buttons["Undo Task"].exists, "There should be a Undo Task button.")
//    }
    
    func testAddingAndDeletingGoalsWorks() {
        XCTAssertTrue(app.buttons["Add Goal"].exists, "There should be a Add Goal button.")
        
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Run")
        app.textFields["Amount"].tap()
        app.typeText("1")
        
        XCTAssertTrue(app.buttons["Add Goal"].exists, "There should be a Add Goal button.")
        
        app.buttons["Save"].tap()

        XCTAssertTrue(app.buttons["Run"].exists, "Run goal should appear in list")
        XCTAssertTrue(
            app.navigationBars.buttons["Add Goal"].exists,
            "There should be a Add Goal button in the toolbar."
        )
        
        app.buttons["Run"].tap()
        app.buttons["Delete Goal"].tap()
        
        XCTAssertTrue(app.buttons["Cancel"].exists, "There should be a Cancel button.")
        XCTAssertTrue(app.buttons["Delete"].exists, "There should be a Cancel button.")
        
        app.buttons["Delete"].tap()
        
        XCTAssertFalse(app.buttons["Run"].exists, "Run goal should no longer in list")
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
        
        XCTAssertFalse(app.staticTexts["1 Day Streak"].exists,
            "There is no longer a 1 day streak."
        )
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
