//
//  TaskAndStreakTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 11/25/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class TaskAndStreakTests: BaseTestCase {
    let persistenceContainer = PersistenceController()
    
    func testDoAndUndoTask() {
        let goal = Goal(context: managedObjectContext)
        
        goal.tasksNeeded = 1
                
        goal.doTask()
        
        XCTAssertEqual(goal.tasksCompleted, 1, "Running doTask 1 time increments tasksCompleted by 1.")
        XCTAssertNotEqual(
            goal.lastStreakIncrease,
            nil,
            "Streak now equals 1, therefore doTask sets the lastStreakIncrease date."
        )
        
        goal.undoTask()
        
        XCTAssertEqual(goal.tasksCompleted, 0, "Running undoTask 1 time increments tasksCompleted down by 1.")
        XCTAssertEqual(
            goal.lastStreakIncrease,
            nil,
            "Streak now equals 0, therefore undoTask sets the lastStreakIncrease date to nil."
        )
    }
    
    func testStreakByIncrement() {
        let goal = Goal(context: managedObjectContext)
        
        goal.tasksNeeded = 1
        goal.doTask()
        
        XCTAssertEqual(
            goal.streak,
            1,
            "Running doTask 1 time increments tasksCompleted up by 1. TasksNeeded == tasksCompleted, streak is now 1."
        )
        
        goal.undoTask()
        
        XCTAssertEqual(
            goal.streak,
            0,
            "goal.tasksCompleted is now less than goal.tasksNeeded. Streak decreases."
        )
        
        goal.doTask()
        
        XCTAssertEqual(
            goal.streak,
            1,
            "Streak equals 1. Streak can re-increase to 1 since it decreased during the period."
        )
        
        goal.doTask()
        
        XCTAssertEqual(
            goal.streak,
            1,
            "Streak still equals 1. Streak cannot increase by more than 1 during the period."
        )
    }
    
    func testStreakUsingTextField() {
        let goal = Goal(context: managedObjectContext)
        
        goal.tasksNeeded = 2
        
        goal.handleTextField(input: 2, oldValue: goal.tasksCompleted)
        
        XCTAssertEqual(
            goal.tasksCompleted,
            2,
            "User inputs 2 into the text field, and goal.tasksCompleted  is then equal to the input value."
        )
        
        XCTAssertEqual(goal.streak, 1, "goal.tasksCompleted equals goal.tasksNeeded. Streak is now 1.")
        
        goal.handleTextField(input: 3, oldValue: goal.tasksCompleted)
        
        XCTAssertEqual(
            goal.streak,
            1,
            "Streak still equals 1. Streak will not increase multiple increments in one period."
        )
        
        goal.handleTextField(input: 1, oldValue: goal.tasksCompleted)

        XCTAssertEqual(goal.streak, 0, "goal.tasksCompleted is now less than goal.tasksNeeded. Streak decreases.")
        
        goal.handleTextField(input: 3, oldValue: goal.tasksCompleted)

        XCTAssertEqual(
            goal.streak,
            1,
            "Streak equals 1. Streak can re-increase to 1 since it decreased during the period."
        )
    }
    
    func testStreakBehaviorWhenEditingTasksNeeded() {
        let goal = Goal(context: managedObjectContext)

        goal.tasksNeeded = 1
        goal.doTask()   // streak is now 1
        goal.tasksNeeded = 2
        goal.doTask()
        
        XCTAssertEqual(
            goal.streak,
            1,
            "Streak will only increase once during the time period. Changing tasksNeeded will not affect this behavior."
        )
    }
    
    func testUpdateStreakFromTimeline() {
        let goal = Goal(context: managedObjectContext)
        goal.timeline = "Daily"
        goal.streak = 2
        
        goal.updateStreakFromTimeline("Daily")
        
        XCTAssertEqual(goal.streak, 2, "Goal timeline didn't change, therefore streak is still 2")
        
        goal.updateStreakFromTimeline("Weekly")
        
        XCTAssertEqual(goal.streak, 1, "Goal timeline changed, therefore streak is now 1")
    }
    
    func testStreakSentence() {
        let goal = Goal(context: managedObjectContext)

        let noStreakSentence = goal.streakSentence()
        
        XCTAssertEqual(noStreakSentence, "", "When there is now streak, the sentence returned is an empty string.")
        
        goal.streak = 1
        goal.timeline = "Daily"
        
        let oneDayStreakSentence = goal.streakSentence()
        
        XCTAssertEqual(oneDayStreakSentence, "1 Day Streak", "Streak equals 1, and timeline equals daily.")
        
        goal.streak = 2
        goal.timeline = "Weekly"
        
        let twoDayStreakSentence = goal.streakSentence()
        
        XCTAssertEqual(twoDayStreakSentence, "2 Week Streak", "Streak equals 2, and timeline equals weekly.")
    }
    
    func testFraction() {
        let goal = Goal(context: managedObjectContext)
        goal.tasksNeeded = 2
        goal.tasksCompleted = 1
        goal.unit = "No Unit"

        let stringOne = goal.createFraction()
        
        XCTAssertEqual(
            stringOne,
            "1/2",
            "Goal unit is 'No Unit', therefore string output is tasks completed over tasks needed"
        )
        
        goal.goalUnit = "Mile"
        
        let stringTwo = goal.createFraction()
        
        XCTAssertEqual(
            stringTwo,
            "1/2 Miles",
            "Goal unit is 'Mile' and tasksCompleted != 1, string output is tasks completed over tasks needed plus Miles"
        )
        
        goal.tasksNeeded = 1
        
        let stringThree = goal.createFraction()
        
        XCTAssertEqual(
            stringThree,
            "1/1 Mile",
            "Goal unit is 'Mile' and tasksCompleted == 1, string output is tasks completed over tasks needed plus Mile"
        )
    }
}
