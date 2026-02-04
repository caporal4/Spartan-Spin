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

        let record = goal.findRecord(for: today, records: recordsArray, timeline: "Daily")
        
        XCTAssertEqual(record?.recordTimeline, "Daily", "Example record timeline is 'Daily'")
        XCTAssertEqual(record?.recordTitle, "Example Goal", "Example record title is 'Example Goal'")
        XCTAssertEqual(record?.recordUnit, "No Unit", "Example record unit is 'Unit'")
        XCTAssertEqual(record?.tasksNeeded, 2, "Example record tasksNeeded is 2")
        XCTAssertEqual(record?.tasksCompleted, 0, "Example record tasksCompleted is 0")
        XCTAssertEqual(record?.streak, 0, "Example record streak is 0")
        XCTAssertEqual(record?.goal, goal, "Example record goal is goal")
        let date = try XCTUnwrap(
            record?.date,
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
    
    func testUpdateRecord() {
        
    }
}
