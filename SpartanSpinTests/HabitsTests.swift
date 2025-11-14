//
//  HabitsTests.swift
//  HabitsTests
//
//  Created by Brendan Caporale on 3/1/25.
//

import CoreData
import XCTest
@testable import Habits

class BaseTestCase: XCTestCase {
    var persistenceController: PersistenceController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        managedObjectContext = persistenceController.container.viewContext
    }
}
