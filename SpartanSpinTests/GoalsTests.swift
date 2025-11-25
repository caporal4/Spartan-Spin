//
//  GoalsTests.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

class BaseTestCase: XCTestCase {
    var persistenceController: PersistenceController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        managedObjectContext = persistenceController.container.viewContext
    }
}
