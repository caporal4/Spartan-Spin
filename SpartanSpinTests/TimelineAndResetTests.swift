//
//  TimelineAndResetTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 11/26/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class TimelineAndResetTests: BaseTestCase {
    let persistenceContainer = PersistenceController()

    func testStreakDailyTimeline() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now
        
        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Daily"
        goal.lastStreakReset = today
        
        // Incrementing the tasksCompleted to increase the streak
        goal.doTask()
        
        guard let oneDayLater = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(today),
            false,
            "shouldResetStreak returns false if the streak was met today."
        )
        XCTAssertEqual(
            goal.shouldResetStreak(oneDayLater),
            false,
            "shouldResetStreak returns false if the streak was met the previos day."
        )
        
        guard let twoDaysLater = Calendar.current.date(byAdding: .day, value: 1, to: oneDayLater) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(twoDaysLater),
            true,
            "shouldResetStreak returns true if the streak wasn't met the previos day."
        )
    }
    
    func testStreakWeeklyTimeline() {
        let goal = Goal(context: managedObjectContext)

        let today = Date.now

        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Weekly"
        goal.lastStreakReset = today
        
        // Incrementing the tasksCompleted to increase the streak
        goal.doTask()
        
        guard let oneWeekLater = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(today),
            false,
            "shouldResetStreak returns false if the streak was met today"
        )
        XCTAssertEqual(
            goal.shouldResetStreak(oneWeekLater),
            false,
            "shouldResetStreak returns false if the streak was met the previos week."
        )
        
        guard let twoWeeksLater = Calendar.current.date(byAdding: .weekOfYear,
            value: 1,
            to: oneWeekLater
        ) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(twoWeeksLater),
            true,
            "shouldResetStreak returns true if the streak wasn't met the previos week."
        )
    }
    
    func testStreakMonthlyTimeline() {
        let goal = Goal(context: managedObjectContext)

        let today = Date.now
        
        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Monthly"
        goal.lastStreakReset = today
        
        // Incrementing the tasksCompleted to increase the streak
        goal.doTask()
        
        guard let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(today),
            false,
            "shouldResetStreak returns false if the streak was met today"
        )
        XCTAssertEqual(
            goal.shouldResetStreak(oneMonthLater),
            false,
            "shouldResetStreak returns false if the streak was met the previos month."
        )
        
        guard let twoMonthsLater = Calendar.current.date(byAdding: .month,
            value: 1,
            to: oneMonthLater
        ) else { return }
        
        XCTAssertEqual(
            goal.shouldResetStreak(twoMonthsLater),
            true,
            "shouldResetStreak returns true if the streak wasn't met the previos month."
        )
    }
    
    func testTaskResetDailyTimeline() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now

        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Daily"
        goal.lastTaskReset = Date.now
        
        goal.doTask()
        
        guard let oneDayLater = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(today),
            false,
            "shouldResetTasksForNewPeriod returns false if it is the same day or if the goal was created today."
        )
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(oneDayLater),
            true,
            "shouldResetTasksForNewPeriod returns true on a new day."
        )
    }
    
    func testTaskResetWeeklyTimeline() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now

        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Weekly"
        goal.lastTaskReset = Date.now
        
        goal.doTask()
        
        guard let oneWeekLater = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(today),
            false,
            "shouldResetTasksForNewPeriod returns false if it is the same week or if the goal was created this week."
        )
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(oneWeekLater),
            true,
            "shouldResetTasksForNewPeriod returns true on a new week."
        )
    }
    
    func testTaskResetMonthlyTimeline() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now

        // New goal created
        goal.tasksNeeded = 1
        goal.timeline = "Monthly"
        goal.lastTaskReset = Date.now
        
        goal.doTask()
        
        guard let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: today) else { return }
        
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(today),
            false,
            "shouldResetTasksForNewPeriod returns false if it is the same month or if the goal was created this month."
        )
        XCTAssertEqual(
            goal.shouldResetTasksForNewPeriod(oneMonthLater),
            true,
            "shouldResetTasksForNewPeriod returns true on a new month."
        )
    }
    
    func testResetStreak() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now

        goal.streak = 1
        goal.tasksCompleted = 1
        goal.lastStreakReset = today
        
        goal.resetStreak()
        
        XCTAssertEqual(goal.streak, 0, "resetStreak sets the streak to 0.")
        XCTAssertEqual(goal.tasksCompleted, 0, "resetStreak sets the tasksCompleted to 0.")
        XCTAssertNotEqual(goal.lastStreakReset, today, "resetStreak sets lastStreakIncrease to Date.now.")
    }
    
    func testResetTasks() {
        let goal = Goal(context: managedObjectContext)
        
        let today = Date.now

        goal.tasksCompleted = 1
        goal.lastStreakReset = today
        
        goal.resetTasks()
        
        XCTAssertEqual(goal.tasksCompleted, 0, "resetTasks sets the tasksCompleted to 0.")
        XCTAssertNotEqual(goal.lastTaskReset, today, "resetStreak sets lastStreakIncrease to Date.now.")
    }
}
