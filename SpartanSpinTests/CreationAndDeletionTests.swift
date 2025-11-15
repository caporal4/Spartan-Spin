//
//  CreationAndDeletionTests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class CreationAndDeletionTests: BaseTestCase {
    func testHabitCreation() {
        let habit = Habit(context: managedObjectContext)
        
        XCTAssertEqual(persistenceController.count(for: Habit.fetchRequest()), 1, "There should be 1 habit")
        
        persistenceController.delete(habit)
        
        XCTAssertEqual(persistenceController.count(for: Habit.fetchRequest()), 0, "There should be 0 habits")
    }
}
