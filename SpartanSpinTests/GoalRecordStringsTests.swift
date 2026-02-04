//
//  GoalRecordStringsTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class GoalRecordStringsTests: BaseTestCase {
    // MARK: - Tests for createFraction()

    func testCreateFractionWithNoUnit() {
        let record = GoalRecord(context: managedObjectContext)
        record.unit = "No Unit"
        record.tasksCompleted = 5
        record.tasksNeeded = 10
        
        XCTAssertEqual(record.createFraction(), "5/10", "Fraction with 'No Unit' should not display unit")
    }

    func testCreateFractionWithSingularUnit() {
        let record = GoalRecord(context: managedObjectContext)
        record.unit = "Mile"
        record.tasksCompleted = 3
        record.tasksNeeded = 1
        
        XCTAssertEqual(record.createFraction(), "3/1 Mile", "Fraction with tasksNeeded = 1 should use singular unit")
    }

    func testCreateFractionWithPluralUnit() {
        let record = GoalRecord(context: managedObjectContext)
        record.unit = "Mile"
        record.tasksCompleted = 5
        record.tasksNeeded = 10
        
        XCTAssertEqual(record.createFraction(), "5/10 Miles", "Fraction with tasksNeeded > 1 should use plural unit")
    }

    func testCreateFractionWithInvalidUnit() {
        let record = GoalRecord(context: managedObjectContext)
        record.unit = "InvalidUnit"
        record.tasksCompleted = 2
        record.tasksNeeded = 5
        
        XCTAssertEqual(
            record.createFraction(),
            "2/5 InvalidUnit",
            "Fraction with invalid unit should display unit as-is"
        )
    }

    func testCreateFractionWithDecimalValues() {
        let record = GoalRecord(context: managedObjectContext)
        record.unit = "Hour"
        record.tasksCompleted = 2.7
        record.tasksNeeded = 5.9
        
        XCTAssertEqual(record.createFraction(), "2/5 Hours", "Fraction should convert decimal values to integers")
    }

    func testCreateFractionWithAllUnits() {
        let units = Units()
        for (index, unit) in units.list.enumerated() {
            let record = GoalRecord(context: managedObjectContext)
            record.unit = unit
            record.tasksCompleted = 5
            record.tasksNeeded = 10
            
            if unit == "No Unit" {
                XCTAssertEqual(record.createFraction(), "5/10", "Fraction with '\(unit)' should not display unit")
            } else {
                let expectedPlural = units.pluralList[index]
                XCTAssertEqual(
                    record.createFraction(),
                    "5/10 \(expectedPlural)",
                    "Fraction with '\(unit)' should display '\(expectedPlural)'"
                )
            }
        }
    }

    // MARK: - Tests for streakSentence()

    func testStreakSentenceWithZeroStreak() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 0
        record.timeline = "Daily"
        
        XCTAssertEqual(record.streakSentence(), "", "Streak sentence with streak = 0 should be empty")
    }

    func testStreakSentenceDaily() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 5
        record.timeline = "Daily"
        
        XCTAssertEqual(record.streakSentence(), "5 Day Streak", "Daily timeline should display 'Day Streak'")
    }

    func testStreakSentenceWeekly() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 3
        record.timeline = "Weekly"
        
        XCTAssertEqual(record.streakSentence(), "3 Week Streak", "Weekly timeline should display 'Week Streak'")
    }

    func testStreakSentenceMonthly() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 12
        record.timeline = "Monthly"
        
        XCTAssertEqual(record.streakSentence(), "12 Month Streak", "Monthly timeline should display 'Month Streak'")
    }

    func testStreakSentenceWithInvalidTimeline() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 7
        record.timeline = "Invalid"
        
        XCTAssertEqual(record.streakSentence(), "", "Streak sentence with invalid timeline should be empty")
    }

    func testStreakSentenceWithNegativeStreak() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = -5
        record.timeline = "Daily"
        
        XCTAssertEqual(record.streakSentence(), "", "Streak sentence with negative streak should be empty")
    }

    func testStreakSentenceWithSingleDayStreak() {
        let record = GoalRecord(context: managedObjectContext)
        record.streak = 1
        record.timeline = "Daily"
        
        XCTAssertEqual(record.streakSentence(), "1 Day Streak", "Streak sentence should work with streak = 1")
    }
}
