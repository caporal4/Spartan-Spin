//
//  SpartanSpin-CoreDataHelpers.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension Habit {
    var habitTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var habitUnit: String {
        get { unit ?? "" }
        set { unit = newValue }
    }
    
    var habitTimeline: String {
        get { timeline ?? "" }
        set { timeline = newValue }
    }
    
    var habitID: UUID {
        id ?? UUID()
    }
    
    var habitReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }
    
    static func example(controller: PersistenceController) -> Habit {
        let controller = controller
        let viewContext = controller.container.viewContext

        let habit = Habit(context: viewContext)
        habit.title = "Example Habit"
        habit.id = UUID()
        habit.tasksNeeded = 2
        habit.unit = "No Unit"
        habit.lastStreakReset = Date.now
        habit.lastTaskReset = Date.now
        habit.streak = 0
        habit.tasksCompleted = 0
        return habit
    }
}
