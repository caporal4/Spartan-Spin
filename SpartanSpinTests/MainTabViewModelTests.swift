//
//  MainTabViewModelTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import SwiftUI
import XCTest
@testable import SpartanSpin

final class MainTabViewModelTests: BaseTestCase {
    let testController = PersistenceController(inMemory: true)
    let calendar = Calendar.current
    let today = Date.now
    
    func testCreateNewRecords() {
        let viewModel = MainTabView.ViewModel(persistenceController: testController)
        
        testController.createSampleData()
        viewModel.createNewRecords()
        
        XCTAssertEqual(5, viewModel.goalRecords.count, "createNewRecords should create a record for each goal")

        viewModel.createNewRecords()
        
        XCTAssertEqual(
            5,
            viewModel.goalRecords.count,
            "createNewRecords only creates records for goals without records"
        )
    }
}
