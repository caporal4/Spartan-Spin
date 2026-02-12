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
    var testController: PersistenceController!
    var viewModel: MainTabView.ViewModel!
    let calendar = Calendar.current
    let today = Date.now
    
    override func setUp() {
        super.setUp()
        testController = PersistenceController(inMemory: true)
        viewModel = MainTabView.ViewModel(persistenceController: testController)
    }
    
    override func tearDown() {
        viewModel = nil
        testController = nil
        super.tearDown()
    }
    
    func testCreateNewRecords() {
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
    
    func testCalculateNewDate() throws {
        let january = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let february = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        let march = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)))
        
        viewModel.displayedMonth = february
        
        viewModel.calculateNewDate(amount: -1)
        
        XCTAssertTrue(calendar.isDate(january, equalTo: viewModel.displayedMonth, toGranularity: .month))
        
        viewModel.calculateNewDate(amount: 1)
        viewModel.calculateNewDate(amount: 1)

        XCTAssertTrue(calendar.isDate(march, equalTo: viewModel.displayedMonth, toGranularity: .month))
    }
    
    func testCreateHistoricRecordsDaily() throws {
        let januaryFirst = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let twoDaysLater = try XCTUnwrap(calendar.date(byAdding: DateComponents(day: 2), to: januaryFirst))
        
        testController.createSampleData(on: januaryFirst)
        viewModel.createNewRecords(for: januaryFirst)
                
        viewModel.createHistoricRecords(for: twoDaysLater)
        viewModel.createNewRecords(for: twoDaysLater)

        XCTAssertEqual(viewModel.goalRecords.count, 9)
    }
    
    func testCreateHistoricRecordsWeekly() throws {
        let januaryFirst = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let oneWeekLater = try XCTUnwrap(calendar.date(byAdding: DateComponents(day: 7), to: januaryFirst))
        
        testController.createSampleData(on: januaryFirst)
        viewModel.createNewRecords(for: januaryFirst)
                
        viewModel.createHistoricRecords(for: oneWeekLater)
        viewModel.createNewRecords(for: oneWeekLater)

        XCTAssertEqual(viewModel.goalRecords.count, 21)
    }
    
    func testCreateHistoricRecordsMonthly() throws {
        let januaryFirst = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let oneMonthLater = try XCTUnwrap(calendar.date(byAdding: DateComponents(day: 31), to: januaryFirst))
        
        testController.createSampleData(on: januaryFirst)
        viewModel.createNewRecords(for: januaryFirst)
                
        viewModel.createHistoricRecords(for: oneMonthLater)
        viewModel.createNewRecords(for: oneMonthLater)

        XCTAssertEqual(viewModel.goalRecords.count, 76)
    }
    
    func testMonthTitle() throws {
        let january = try XCTUnwrap(
            viewModel.calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
            "Should create January date"
        )
        viewModel.displayedMonth = january
        XCTAssertEqual(viewModel.monthTitle, "January 2026", "Month title should format correctly")
    }
    
    func testGoalsArePopulatedOnInit() {
        testController.createSampleData()
        let newViewModel = MainTabView.ViewModel(persistenceController: testController)
        
        XCTAssertEqual(newViewModel.goals.count, 5, "Goals should be fetched on init")
        XCTAssertEqual(
            newViewModel.goalRecords.count,
            5,
            "Records should be fetched on init (createSampleData creates one record per goal)"
        )
    }

    func testControllerDidChangeContentUpdatesGoals() throws {
        testController.createSampleData()
        
        let initialCount = viewModel.goals.count
        
        // Add a new goal
        let newGoal = Goal(context: testController.container.viewContext)
        newGoal.title = "New Goal"
        newGoal.timeline = "Daily"
        newGoal.tasksNeeded = 2
        testController.save()
        
        // Give fetched results controller time to notify
        let expectation = expectation(description: "Goals updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.goals.count, initialCount + 1, "Goals should update when new goal is added")
    }
    
    func testControllerDidChangeContentUpdatesGoalRecords() throws {
        testController.createSampleData()
        viewModel.createNewRecords()
        
        let initialCount = viewModel.goalRecords.count
        
        // Manually create a new record
        let record = GoalRecord(context: testController.container.viewContext)
        record.title = "New Record"
        record.timeline = "Daily"
        record.date = Date.now
        record.tasksCompleted = 0
        record.tasksNeeded = 2
        testController.save()
        
        // Give fetched results controller time to notify
        let expectation = expectation(description: "Records updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(
            viewModel.goalRecords.count,
            initialCount + 1,
            "Goal records should update when new record is added"
        )
    }
    
    func testRecordCreationStreak() throws {
        let calendar = Calendar.current
        let firstOfJanuary = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)),
            "Should create date for first day of January"
        )
        let secondOfJanuary = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 2)),
            "Should create date for second day of January"
        )
        let thirdOfJanuary = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 3)),
            "Should create date for third day of January"
        )
        
        let goal = Goal.example(controller: testController, date: firstOfJanuary)
        
        goal.doTask()
        goal.doTask()
        
        let firstRecord = try XCTUnwrap(
            goal.findRecord(for: firstOfJanuary, records: viewModel.goalRecords, timeline: "Daily"),
            "There should be a record created for the first of January"
            )
        
        goal.updateRecord(firstRecord)
        
        XCTAssertEqual(firstRecord.streak, 1, "Record should have not have a streak of 1")
        
        viewModel.createHistoricRecords(for: thirdOfJanuary)
        viewModel.createNewRecords(for: thirdOfJanuary)
        
        XCTAssertEqual(viewModel.goalRecords.count, 3, "Three records should have been created in total.")
        
        let secondRecord = try XCTUnwrap(
            goal.findRecord(for: secondOfJanuary, records: viewModel.goalRecords, timeline: "Daily"),
            "There should be a record created for the second of January"
            )
        let thirdRecord = try XCTUnwrap(
            goal.findRecord(for: thirdOfJanuary, records: viewModel.goalRecords, timeline: "Daily"),
            "There should be a record created for the second of January"
            )
        
        XCTAssertEqual(secondRecord.streak, 0, "The second record's streak should be 0.")
        XCTAssertEqual(thirdRecord.streak, 0, "The third record's streak should be 0.")
    }
}
