//
//  GoalRecordEditingTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class GoalRecordEditingTests: BaseTestCase {
    func testExampleRecordCreation() throws {
        let goal = Goal.example(controller: persistenceController)
        let unusedRecordOne = GoalRecord(context: managedObjectContext)
        let unusedRecordTwo = GoalRecord(context: managedObjectContext)
        
        var recordsSet = goal.records as? Set<GoalRecord> ?? Set<GoalRecord>()
        recordsSet.insert(unusedRecordOne)
        recordsSet.insert(unusedRecordTwo)
        
        let recordsArray = Array(recordsSet)
        
        let today = Date.now
        let calendar = Calendar.current

        let record = try XCTUnwrap(
            goal.findRecord(for: today, records: recordsArray, timeline: "Daily"),
            "There should be a record for today"
            )
        
        XCTAssertEqual(record.recordTimeline, "Daily", "Example record timeline is 'Daily'")
        XCTAssertEqual(record.recordTitle, "Example Goal", "Example record title is 'Example Goal'")
        XCTAssertEqual(record.recordUnit, "No Unit", "Example record unit is 'Unit'")
        XCTAssertEqual(record.tasksNeeded, 2, "Example record tasksNeeded is 2")
        XCTAssertEqual(record.tasksCompleted, 0, "Example record tasksCompleted is 0")
        XCTAssertEqual(record.streak, 0, "Example record streak is 0")
        XCTAssertEqual(record.goal, goal, "Example record goal is goal")
        let date = try XCTUnwrap(
            record.date,
            "Record should have date"
            )
        XCTAssertTrue(
                calendar.isDate(date, inSameDayAs: today),
                "Example record should be on the same day as today"
            )
    }
    
    func testFindRecord () throws {
        var records = [GoalRecord]()
        let goal = Goal(context: managedObjectContext)
        let wrongGoal = Goal(context: managedObjectContext)
        let calendar = Calendar.current
        for day in 1...30 {
            let record = GoalRecord(context: managedObjectContext)
            record.goal = goal
            record.title = "Record\(day)"
            record.timeline = "Daily"
            if day == 28 {
                record.timeline = "Weekly"
            } else if day == 29 {
                record.timeline = "Monthly"
            }
            record.date = calendar.date(from: DateComponents(year: 2026, month: 1, day: day))
            records.append(record)
        }
        let firstOfJanuary = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
            "Should create date for first day of January"
        )
        let endOfJanuary = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 31)),
            "Should create date for last day of January"
        )
        let january28 = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 28)),
            "Should create date for 28th of January"
        )
        let january29 = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 29)),
            "Should create date for 29th of January"
        )
        
        let foundRecordOne = goal.findRecord(for: firstOfJanuary, records: records, timeline: "Daily")
        let foundRecordTwo = goal.findRecord(for: endOfJanuary, records: records, timeline: "Daily")
        let foundRecordThree = goal.findRecord(for: january28, records: records, timeline: "Weekly")
        let foundRecordFour = goal.findRecord(for: january29, records: records, timeline: "Monthly")
        let foundRecordFive = wrongGoal.findRecord(for: firstOfJanuary, records: records, timeline: "Daily")
        
        XCTAssertNotNil(foundRecordOne, "There is a daily record for the 1st of January")
        XCTAssertNil(foundRecordTwo, "There is no record for the 31st of January")
        XCTAssertNotNil(foundRecordThree, "There is a weekly record for the 28th of January")
        XCTAssertNotNil(foundRecordFour, "There is a monthly record for the 29th of January")
        XCTAssertNil(foundRecordFive, "There is not a record for wrongGoal")
    }
    
    func testUpdateRecord() throws {
            let goal = Goal.example(controller: persistenceController)
            let calendar = Calendar.current
            let today = Date.now

            let recordsSet = goal.records as? Set<GoalRecord> ?? Set<GoalRecord>()
            let recordsArray = Array(recordsSet)

            let record = try XCTUnwrap(
                goal.findRecord(for: today, records: recordsArray, timeline: "Daily"),
                "There should be a record created today"
            )

            XCTAssertEqual(record.tasksCompleted, 0, "Record should not have any tasks completed")

            goal.doTask()
            goal.updateRecord(record)

            XCTAssertEqual(record.tasksCompleted, 1, "Record should have 1 task completed")
            XCTAssertEqual(record.streak, 0, "Record streak should not update until tasks are completed")

            goal.doTask()
            goal.updateRecord(record)

            XCTAssertEqual(record.tasksCompleted, 2, "Record should have 2 tasks completed")
            XCTAssertEqual(record.streak, 1, "Record streak should update when streak increases")

            goal.undoTask()
            goal.updateRecord(record)

            XCTAssertEqual(record.tasksCompleted, 1, "Record should have 1 task completed")
            XCTAssertEqual(record.streak, 0, "Record streak should reset when streak is lost")

            let yesterday = try XCTUnwrap(
                calendar.date(byAdding: .day, value: -1, to: today),
                "Should be able to compute yesterday"
            )
            goal.streak = 3
            goal.tasksCompleted = 0
            goal.lastStreakIncrease = yesterday
            record.streak = 0

            goal.doTask()
            goal.updateRecord(record)

            XCTAssertEqual(record.streak, 0, "Record streak should not update from a pre-existing streak mid-progress")
        }
    
    func testEditRecordToday() throws {
            let goal = Goal.example(controller: persistenceController)

            let today = Date.now
            let recordsSet = goal.records as? Set<GoalRecord> ?? Set<GoalRecord>()
            let recordsArray = Array(recordsSet)

            let record = try XCTUnwrap(
                goal.findRecord(for: today, records: recordsArray, timeline: "Daily"),
                "There should be a record for today"
            )

            // Confirm baseline values before any edits
            XCTAssertEqual(record.recordTitle, "Example Goal", "Record title should match the original goal title")
            XCTAssertEqual(record.recordUnit, "No Unit", "Record unit should match the original goal unit")
            XCTAssertEqual(record.tasksNeeded, 2, "Record tasksNeeded should match the original goal tasksNeeded")

            // Simulate user editing the goal title and unit via EditGoalViewModel.validateChanges
            goal.goalTitle = "Updated Goal"
            goal.unit = "Mile"
            goal.tasksNeeded = 5

            // updateRecord only syncs tasksCompleted and streak — not title, unit, or tasksNeeded
            goal.updateRecord(record)

            XCTAssertEqual(record.recordTitle, "Example Goal", "Today's record title should not change until tomorrow")
            XCTAssertEqual(record.recordUnit, "No Unit", "Today's record unit should not change until tomorrow")
            XCTAssertEqual(record.tasksNeeded, 2, "Today's record tasksNeeded should not change until tomorrow")
        }

        func testEditRecordTomorrow() throws {
            let goal = Goal.example(controller: persistenceController)

            let today = Date.now
            let calendar = Calendar.current

            let tomorrow = try XCTUnwrap(
                calendar.date(byAdding: .day, value: 1, to: today),
                "Should be able to compute tomorrow's date"
            )

            // Simulate user editing the goal title, unit, and tasksNeeded
            goal.goalTitle = "Updated Goal"
            goal.unit = "Mile"
            goal.tasksNeeded = 5

            // Creating a record for tomorrow calls fullyUpdateRecord, which syncs all goal properties
            goal.createRecord(on: tomorrow, context: managedObjectContext)

            let allRecords = (goal.records as? Set<GoalRecord>).map(Array.init) ?? []

            let tomorrowRecord = try XCTUnwrap(
                goal.findRecord(for: tomorrow, records: allRecords, timeline: "Daily"),
                "There should be a record for tomorrow"
            )

            XCTAssertEqual(
                tomorrowRecord.recordTitle,
                "Updated Goal",
                "Tomorrow's record should reflect the updated goal title"
            )
            XCTAssertEqual(tomorrowRecord.recordUnit, "Mile", "Tomorrow's record should reflect the updated goal unit")
            XCTAssertEqual(tomorrowRecord.tasksNeeded, 5, "Tomorrow's record should reflect the updated tasksNeeded")
            XCTAssertEqual(tomorrowRecord.tasksCompleted, 0, "Tomorrow's record should start with zero tasks completed")
            XCTAssertEqual(tomorrowRecord.streak, 0, "Tomorrow's record should start with a streak of 0")
        }
}
