//
//  GoalDeletionRecordTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/13/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class GoalDeletionRecordTests: BaseTestCase {
    func testDeleteGoal_UsingViewModel_DeletesTodaysRecord() {
        // Given: Goal with today's record
        let goal = createGoal(title: "Test Goal")
        let today = Date()
        goal.createRecord(on: today, context: managedObjectContext)
        
        let recordsBefore = fetchRecords(for: today)
        XCTAssertEqual(recordsBefore.count, 1, "Should have one record before deletion")
        
        // When: Deleting using actual GoalViewModel
        let viewModel = GoalView.ViewModel(
            persistenceController: persistenceController,
            goal: goal
        )
        viewModel.delete(goal)
        
        // Then: Today's record should be deleted
        let recordsAfter = fetchRecords(for: today)
        XCTAssertEqual(recordsAfter.count, 0, "Today's record should be deleted")
        
        // And: Goal should be deleted
        let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        let goals = try? managedObjectContext.fetch(goalRequest)
        XCTAssertEqual(goals?.count, 0, "Goal should be deleted")
    }
    
    func testSwipeToDelete_UsingViewModel_DeletesTodaysRecord() {
        // Given: Two goals with today's records
        let goal1 = createGoal(title: "Goal 1")
        let goal2 = createGoal(title: "Goal 2")
        let today = Date()
        
        goal1.createRecord(on: today, context: managedObjectContext)
        goal2.createRecord(on: today, context: managedObjectContext)
        
        XCTAssertEqual(fetchRecords(for: today).count, 2)
        
        // When: Swipe-to-delete using actual ContentViewModel
        let viewModel = ContentView.ViewModel(persistenceController: persistenceController)
        let goals = [goal1, goal2]
        let offsets = IndexSet(integer: 0) // Delete goal1
        
        viewModel.swipeToDelete(goals: goals, offsets)
        
        // Then: Only goal2's record remains today
        let recordsAfter = fetchRecords(for: today)
        XCTAssertEqual(recordsAfter.count, 1, "Should have one record remaining")
        XCTAssertEqual(recordsAfter.first?.goal, goal2, "Remaining record should be goal2's")
        
        // And: goal1 should be deleted
        let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        let remainingGoals = try? managedObjectContext.fetch(goalRequest)
        XCTAssertEqual(remainingGoals?.count, 1, "Should have one goal remaining")
        XCTAssertEqual(remainingGoals?.first, goal2, "Remaining goal should be goal2")
    }
    
    func testDeleteGoal_WithPartialProgress_DeletesTodaysRecord() {
        // Given: Goal with partial progress today
        let goal = createGoal(title: "Test Goal")
        goal.tasksNeeded = 5
        goal.tasksCompleted = 3
        
        let today = Date()
        goal.createRecord(on: today, context: managedObjectContext)
        
        let record = fetchRecords(for: today).first
        XCTAssertEqual(record?.tasksCompleted, 3, "Should have partial progress")
        
        // When: Deleting using ViewModel
        let viewModel = GoalView.ViewModel(
            persistenceController: persistenceController,
            goal: goal
        )
        viewModel.delete(goal)
        
        // Then: Today's record deleted (progress is lost)
        let recordsAfter = fetchRecords(for: today)
        XCTAssertEqual(recordsAfter.count, 0, "Record with progress should still be deleted")
    }
    
    func testDeleteMultipleGoals_DeletesAllTodaysRecords() {
        // Given: Three goals with today's records
        let goal1 = createGoal(title: "Goal 1")
        let goal2 = createGoal(title: "Goal 2")
        let goal3 = createGoal(title: "Goal 3")
        let today = Date()
        
        goal1.createRecord(on: today, context: managedObjectContext)
        goal2.createRecord(on: today, context: managedObjectContext)
        goal3.createRecord(on: today, context: managedObjectContext)
        
        XCTAssertEqual(fetchRecords(for: today).count, 3)
        
        // When: Delete using ContentViewModel swipe
        let viewModel = ContentView.ViewModel(persistenceController: persistenceController)
        let goals = [goal1, goal2, goal3]
        let offsets = IndexSet([0, 2]) // Delete goal1 and goal3
        
        viewModel.swipeToDelete(goals: goals, offsets)
        
        // Then: Only goal2's record remains
        let records = fetchRecords(for: today)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.goal, goal2)
    }
    
    func testDeleteGoal_NoRecordToday_DoesNotError() {
        // Given: Goal with NO record today
        let goal = createGoal(title: "Test Goal")
        
        // When: Deleting the goal using ViewModel
        let viewModel = GoalView.ViewModel(
            persistenceController: persistenceController,
            goal: goal
        )
        viewModel.delete(goal)
        
        // Then: Should complete without error
        let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        let goals = try? managedObjectContext.fetch(goalRequest)
        XCTAssertEqual(goals?.count, 0, "Goal should be deleted")
    }
    
    // Note: These tests use direct deletion since ViewModels use Date() internally
    
    func testDeleteGoal_PreservesHistoricalRecords() {
        // Given: Goal with records on multiple days
        let goal = createGoal(title: "Test Goal")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let today = Date()
        
        goal.createRecord(on: twoDaysAgo, context: managedObjectContext)
        goal.createRecord(on: yesterday, context: managedObjectContext)
        goal.createRecord(on: today, context: managedObjectContext)
        
        XCTAssertEqual(fetchRecords(for: twoDaysAgo).count, 1)
        XCTAssertEqual(fetchRecords(for: yesterday).count, 1)
        XCTAssertEqual(fetchRecords(for: today).count, 1)
        
        // When: Deleting using ViewModel (deletes today's record)
        let viewModel = GoalView.ViewModel(
            persistenceController: persistenceController,
            goal: goal
        )
        viewModel.delete(goal)
        
        // Then: Historical records preserved, today's deleted
        XCTAssertEqual(fetchRecords(for: twoDaysAgo).count, 1, "Old record preserved")
        XCTAssertEqual(fetchRecords(for: yesterday).count, 1, "Yesterday's record preserved")
        XCTAssertEqual(fetchRecords(for: today).count, 0, "Today's record deleted")
    }
    
    func testDeleteGoal_WithWeeklyTimeline_DeletesTodaysRecord() {
        // Given: Weekly goal with this week's record
        let goal = createGoal(title: "Weekly Goal")
        goal.timeline = "Weekly"
        
        let today = Date()
        goal.createRecord(on: today, context: managedObjectContext)
        
        XCTAssertEqual(fetchRecords(for: today).count, 1)
        
        // When: Deleting using ViewModel
        let viewModel = GoalView.ViewModel(
            persistenceController: persistenceController,
            goal: goal
        )
        viewModel.delete(goal)
        
        // Then: This week's record deleted
        XCTAssertEqual(fetchRecords(for: today).count, 0)
    }
        
    private func createGoal(title: String) -> Goal {
        let goal = Goal(context: managedObjectContext)
        goal.id = UUID()
        goal.title = title
        goal.timeline = "Daily"
        goal.tasksNeeded = 1
        goal.tasksCompleted = 0
        goal.unit = "No Unit"
        return goal
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func fetchRecords(for date: Date) -> [GoalRecord] {
        let fetchRequest: NSFetchRequest<GoalRecord> = GoalRecord.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        return (try? managedObjectContext.fetch(fetchRequest)) ?? []
    }
}
