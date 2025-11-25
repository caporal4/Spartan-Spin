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
    func testGoalCreation() {
        let goal = Goal(context: managedObjectContext)
        
        XCTAssertEqual(persistenceController.count(for: Goal.fetchRequest()), 1, "There should be 1 goal")
        
        persistenceController.delete(goal)
        
        XCTAssertEqual(persistenceController.count(for: Goal.fetchRequest()), 0, "There should be 0 goals")
    }
}
