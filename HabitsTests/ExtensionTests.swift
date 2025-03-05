//
//  ExtensionTests.swift
//  HabitsTests
//
//  Created by Brendan Caporale on 3/4/25.
//

import CoreData
import XCTest
@testable import Habits

final class ExtensionTests: BaseTestCase {
    func testHabitTitleUnwrap() {
        let habit = Habit(context: managedObjectContext)

        habit.title = "Example habit"
        XCTAssertEqual(habit.habitTitle, "Example habit", "Changing title should also change habitTitle.")

        habit.habitTitle = "Updated habit"
        XCTAssertEqual(habit.title, "Updated habit", "Changing habitTitle should also change title.")
    }
    
    func testHabitUnitUnwrap() {
        let habit = Habit(context: managedObjectContext)

        habit.unit = "Count"
        XCTAssertEqual(habit.habitUnit, "Count", "Changing unit should also change habitUnit.")

        habit.habitUnit = "Mile"
        XCTAssertEqual(habit.unit, "Mile", "Changing habitUnit should also change unit.")
    }
    
    func testHabitIdUnwrap() {
        let habit = Habit(context: managedObjectContext)
        habit.id = UUID()

        XCTAssertEqual(habit.habitID, habit.id, "Changing habit id should also change habitID.")
    }
}
