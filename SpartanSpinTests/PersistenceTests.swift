//
//  PersistenceTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 12/2/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class PersistenceTests: BaseTestCase {
    let persistenceContainer = PersistenceController()
    
    func testLevenshteinDistance() {
        let monthlyMove = "Push-ups"
        let goal1 = Goal(context: managedObjectContext)
        let goal2 = Goal(context: managedObjectContext)
        let goal3 = Goal(context: managedObjectContext)
        goal1.title = "Run"
        goal2.title = "Feed Dog"
        goal3.title = "Push-ups"
        let goals = [goal1, goal2, goal3]
        
        XCTAssertTrue(
            persistenceContainer.isMonthlyMoveActive(string: monthlyMove, goals: goals),
            "isMonthlyMoveActive should return true since Push-ups is an active goal and monthlyMove is Push-ups."
        )
        
        goal3.title = "Pushups"

        XCTAssertTrue(
            persistenceContainer.isMonthlyMoveActive(string: monthlyMove, goals: goals),
            "isMonthlyMoveActive should return true since Pushups is one character off from Push-ups."
        )
        
        goal3.title = "Pushps"

        XCTAssertTrue(
            persistenceContainer.isMonthlyMoveActive(string: monthlyMove, goals: goals),
            "isMonthlyMoveActive should return true since Pushups is two characters off from Push-ups."
        )
        
        goal3.title = "Pushs"

        XCTAssertFalse(
            persistenceContainer.isMonthlyMoveActive(string: monthlyMove, goals: goals),
            "isMonthlyMoveActive should return false since Pushups is three characters off from Push-ups."
        )
    }
}
