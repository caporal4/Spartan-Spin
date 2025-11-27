//
//  SpartanSpinBasicUITests.swift
//  SpartanSpinUITests
//
//  Created by Brendan Caporale on 11/26/25.
//

import XCTest

final class SpartanSpinBasicUITests: XCTestCase {
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
    
    func testForButtons() {
        XCTAssertTrue(app.buttons["Add Goal"].exists, "There should be an Add Goal button.")
        XCTAssertTrue(app.buttons["Add Sample Goals"].exists, "There should be an Add Sample Goals debug button.")
        
        XCTAssertTrue(app.tabBars.buttons["List"].exists)
        XCTAssertTrue(app.tabBars.buttons["Calendar"].exists)
        
        app.buttons["Add Sample Goals"].tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Add Goal"].exists, "There should be an Add Samples toolbar button.")
        XCTAssertTrue(
            app.navigationBars.buttons["ADD SAMPLES"].exists,
            "There should be an ADD SAMPLES debug toolbar button."
        )
        XCTAssertTrue(
            app.navigationBars.buttons["DELETE SAMPLES"].exists,
            "There should be an DELETE SAMPLES toolbar debug button."
        )
        XCTAssertTrue(app.tabBars.buttons["List"].exists)
        XCTAssertTrue(app.tabBars.buttons["Calendar"].exists)
        
        app.buttons["Add Goal"].tap()
        
        XCTAssertTrue(app.textFields["Title TextField"].exists, "There should be a title text field.")
        XCTAssertTrue(app.textFields["Amount TextField"].exists, "There should be an amount text field.")
        XCTAssertTrue(
            app.buttons["Unit Picker"].exists,
            "There should be a unit picker."
        )
        XCTAssertTrue(
            app.buttons["Timeline Picker"].exists,
            "There should be a timeline picker."
        )
        XCTAssertTrue(
            app.navigationBars.buttons["Save"].exists,
            "There should be a save toolbar button."
        )
        XCTAssertTrue(app.switches["Reminders Toggle"].exists, "There should be a reminder toggle.")

        app.swipeDown()
        
        app.buttons["Brush Teeth"].tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Edit Goal"].exists, "There should be a Edit Goal toolbar button.")
        XCTAssertTrue(
    app.navigationBars.buttons["Delete Goal"].exists,
    "There should be a Delete Goal toolbar button."
        )
        XCTAssertTrue(app.buttons["Complete Task"].exists, "There should be a Complete Task button.")
        XCTAssertTrue(app.buttons["Undo Task"].exists, "There should be a Undo Task button.")
        XCTAssertFalse(app.tabBars.buttons["List"].exists)
        XCTAssertFalse(app.tabBars.buttons["Calendar"].exists)
    }
    
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
}
