//
//  SpartanSpinUITestsMonthlyMove.swift
//  SpartanSpinUITests
//
//  Created by Brendan Caporale on 12/11/25.
//

import XCTest

final class SpartanSpinUITestsMonthlyMove: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
    func testMoveOfTheMonthButton() {
        XCTAssertTrue(app.buttons["Move of the Month"].exists, "There should be a Move of the Month button.")
        
        app.buttons["Add Sample Goals"].tap()

        XCTAssertTrue(app.buttons["Move of the Month"].exists, "There should be a Move of the Month button.")
        
        app.buttons["Move of the Month"].tap()
        app.textFields["Amount TextField"].tap()
        app.typeText("1")
        
        XCTAssertFalse(
            app.staticTexts["Enter the goal title here"].exists,
            "Move of the month should be pre populated, meaning placeholder text will not be there."
        )
        XCTAssertTrue(
            app.staticTexts["Repitition"].exists,
            "The unit should be preset to Repititions for move of the month."
        )
    }
    
    func testMonthlyMoveButtonPhrase() {
        var text = app.staticTexts["Tap here to add as a goal"]
        
        XCTAssertTrue(text.exists, "Phrase at bottom of monthly move button should read 'Tap here to add as a goal'")
        
        app.buttons["Add Sample Goals"].tap()
        
        XCTAssertTrue(text.exists, "Phrase at bottom of monthly move button should read 'Tap here to add as a goal'")
            
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Pushups")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        
        text = app.staticTexts["Tap here to view goal"]
        
        XCTAssertTrue(text.exists, "Phrase at bottom of monthly move button should read 'Tap here to view goal'")
        
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Push-u")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        
        text = app.staticTexts["Tap here to view goals"]
        
        XCTAssertTrue(text.exists, "Phrase at bottom of monthly move button should read 'Tap here to view goals'")
    }
    
    func testMonthlyMoveListSheet() {
        app.launchArguments.append("-forceMonthlyMove")
        app.launchArguments.append("Push-ups")
        app.terminate()
        app.launch()

        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Push-ups")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        
        app.buttons["Move of the Month"].tap()

        XCTAssertTrue(
            app.buttons["Edit Goal"].exists,
            "Edit goal button exists, which means the navigation link worked and the user is in the edit goal view."
        )
                
        app.buttons["Back"].tap()
        app.buttons["Add Goal"].tap()
        app.textFields["Enter the goal title here"].tap()
        app.typeText("Push-ups")
        app.textFields["Amount"].tap()
        app.typeText("2")
        app.buttons["Save"].tap()
        
        app.buttons["Move of the Month"].tap()
        
        XCTAssertTrue(
            app.otherElements["Monthly Move List Sheet"].exists,
            "If 2 or more goals match the monthly move, a sheet with a list of the goals will appear when tapped."
        )
        XCTAssertTrue(
            app.staticTexts["Spartan Spin"].exists,
            "Navigation title 'Spartan Spin' exists."
        )
        
        app.buttons["Push-ups"].firstMatch.tap()
        
        XCTAssertTrue(
            app.buttons["Edit Goal"].exists,
            "Edit goal button exists, which means the navigation link worked and the user is in the edit goal view."
        )
        XCTAssertTrue(
            app.staticTexts["Push-ups"].exists,
            "Navigation title of goal title exists."
        )
        
        app.buttons["Back"].tap()
        app.swipeDown()
        
        XCTAssertFalse(
            app.otherElements["Monthly Move List Sheet"].exists,
            "Sheet was swiped away."
        )
    }
}
