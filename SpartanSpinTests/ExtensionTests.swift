//
//  ExtensionTests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class ExtensionTests: BaseTestCase {
    let persistenceContainer = PersistenceController()
    
    func testGoalTitleUnwrap() {
        let goal = Goal(context: managedObjectContext)

        goal.title = "Test goal"
        XCTAssertEqual(goal.goalTitle, "Test goal", "Changing title should also change goalTitle.")

        goal.goalTitle = "Updated goal"
        XCTAssertEqual(goal.title, "Updated goal", "Changing goalTitle should also change title.")
    }
    
    func testGoalUnitUnwrap() {
        let goal = Goal(context: managedObjectContext)

        goal.unit = "Repitition"
        XCTAssertEqual(goal.goalUnit, "Repitition", "Changing unit should also change goalUnit.")

        goal.goalUnit = "Mile"
        XCTAssertEqual(goal.unit, "Mile", "Changing goalUnit should also change unit.")
    }
    
    func testGoalTimelineUnwrap() {
        let goal = Goal(context: managedObjectContext)

        goal.timeline = "Monthly"
        XCTAssertEqual(goal.goalTimeline, "Monthly", "Changing timeline should also change goalTimeline.")

        goal.goalTimeline = "Weekly"
        XCTAssertEqual(goal.timeline, "Weekly", "Changing goalTimeline should also change timeline.")
    }
    
    func testGoalIdUnwrap() {
        let goal = Goal(context: managedObjectContext)
        goal.id = UUID()

        XCTAssertEqual(goal.goalID, goal.id, "Changing goal id should also change goalID.")
    }
    
    func testGoalReminderFrequencyUnwrap() {
        let goal = Goal(context: managedObjectContext)
        
        goal.reminderFrequency = "Monthly"
        XCTAssertEqual(
            goal.goalReminderFrequency, 
            "Monthly",
            "Changing reminderFrequency should also change goalreminderFrequency."
        )
        
        goal.goalReminderFrequency = "Daily"
        XCTAssertEqual(
            goal.reminderFrequency,
            "Daily",
            "Changing goalreminderFrequency should also change reminderFrequency."
        )
    }
    
    func testGoalReminderTimeUnwrap() {
        let goal = Goal(context: managedObjectContext)
        
        let future = Date.now.addingTimeInterval(3600)
        let past = Date.now.addingTimeInterval(-3600)
        goal.reminderTime = future
        XCTAssertEqual(
            goal.goalReminderTime,
            future,
            "Changing reminderTime should also change goalreminderTime."
        )
        
        goal.goalReminderTime = past
        XCTAssertEqual(
            goal.reminderTime,
            past,
            "Changing goalreminderTime should also change reminderTime."
        )
    }
    
    func testGoalWeeklyRemindersUnwrap() {
        let goal = Goal(context: managedObjectContext)
        
        goal.weeklyReminderTimes = [1, 2, 3]
        XCTAssertEqual(
            goal.goalWeeklyReminders,
            [1, 2, 3],
            "Changing weeklyReminderTimes should also change goalWeeklyReminders."
        )
        
        goal.goalWeeklyReminders = [4, 5, 6, 7]
        XCTAssertEqual(
            goal.weeklyReminderTimes,
            [4, 5, 6, 7],
            "Changing goalWeeklyReminders should also change weeklyReminderTimes."
        )
    }
    
    func testGoalMonthlyRemindersUnwrap() {
        let goal = Goal(context: managedObjectContext)
        
        goal.monthlyReminderTimes = [1, 2, 3]
        XCTAssertEqual(
            goal.goalMonthlyReminders,
            [1, 2, 3],
            "Changing monthlyReminderTimes should also change goalMonthlyReminders."
        )
        
        goal.goalMonthlyReminders = [27, 28, 29, 30]
        XCTAssertEqual(
            goal.monthlyReminderTimes,
            [27, 28, 29, 30],
            "Changing goalMonthlyReminders should also change monthlyReminderTimes."
        )
    }
    
    func testExampleData() {
        let goal = Goal.example(controller: persistenceContainer)
        XCTAssertEqual(goal.goalTitle, "Example Goal", "Example Goal title should be Example Goal.")
        XCTAssertEqual(goal.goalUnit, "No Unit", "Example Goal unit should be No Unit.")
        XCTAssertEqual(goal.tasksNeeded, 2, "Example Goal tasks needed should be 2.")
        XCTAssertEqual(goal.tasksCompleted, 0, "Example Goal tasks completed should be 0.")
        XCTAssertEqual(goal.streak, 0, "Example Goal streak should be 0.")
        XCTAssertEqual(goal.timeline, "Daily", "Example Goal timelin should be Daily.")
    }
}
