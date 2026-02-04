//
//  ArrayExtensionTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class ArrayExtensionTests: BaseTestCase {
    func testGoalFilters() {
        var goals = [Goal]()
        
        let goalOne = Goal(context: managedObjectContext)
        goalOne.timeline = "Daily"
        goals.append(goalOne)
        
        let goalTwo = Goal(context: managedObjectContext)
        goalTwo.timeline = "Weekly"
        goals.append(goalTwo)

        let goalThree = Goal(context: managedObjectContext)
        goalThree.timeline = "Weekly"
        goals.append(goalThree)

        let goalFour = Goal(context: managedObjectContext)
        goalFour.timeline = "Monthly"
        goals.append(goalFour)

        let goalFive = Goal(context: managedObjectContext)
        goalFive.timeline = "Monthly"
        goals.append(goalFive)

        let goalSix = Goal(context: managedObjectContext)
        goalSix.timeline = "Monthly"
        goals.append(goalSix)

        let dailyGoals = goals.dailyGoals
        let weeklyGoals = goals.weeklyGoals
        let monthlyGoals = goals.monthlyGoals
        
        XCTAssertEqual(1, dailyGoals.count, "dailyGoals should have 1 goal")
        XCTAssertEqual(2, weeklyGoals.count, "weeklyGoals should have 2 goals")
        XCTAssertEqual(3, monthlyGoals.count, "monthlyGoals should have 3 goal3")
    }
}
