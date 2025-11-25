//
//  DevelopmentTests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreation() {
        persistenceController.createSampleData()
        
        XCTAssertEqual(persistenceController.count(for: Goal.fetchRequest()), 5, "There should be 5 sample goals.")
    }
    
    func testDeleteAllWorks() {
        persistenceController.createSampleData()
        persistenceController.deleteAll()
        
        XCTAssertEqual(persistenceController.count(for: Goal.fetchRequest()), 0, "There should be 0 sample goals.")
    }
}
