//
//  SpartanSpin-CoreDataHelpers.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension Goal {
    var goalTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var goalUnit: String {
        get { unit ?? "" }
        set { unit = newValue }
    }
    
    var goalTimeline: String {
        get { timeline ?? "" }
        set { timeline = newValue }
    }
    
    var goalID: UUID {
        id ?? UUID()
    }
    
    var goalReminderFrequency: String {
        get { reminderFrequency ?? "" }
        set { reminderFrequency = newValue }
    }
    
    var goalReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }
    
    var goalWeeklyReminders: Set<Int> {
        get { weeklyReminderTimes ?? [] }
        set { weeklyReminderTimes = newValue }
    }
    
    var goalMonthlyReminders: Set<Int> {
        get { monthlyReminderTimes ?? [] }
        set { monthlyReminderTimes = newValue }
    }
    
    static func example(controller: PersistenceController) -> Goal {
        let controller = controller
        let viewContext = controller.container.viewContext

        let goal = Goal(context: viewContext)
        goal.title = "Example Goal"
        goal.id = UUID()
        goal.tasksNeeded = 2
        goal.unit = "No Unit"
        goal.timeline = "Daily"
        goal.lastStreakReset = Date.now
        goal.lastTaskReset = Date.now
        goal.streak = 0
        goal.tasksCompleted = 0
        return goal
    }
}
