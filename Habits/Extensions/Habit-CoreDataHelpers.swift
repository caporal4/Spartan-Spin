//
//  Habit-CoreDataHelpers.swift
//  Habits
//
//  Created by Brendan Caporale on 3/1/25.
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
    
    var habitID: UUID {
        id ?? UUID()
    }
    
    var habitTasksNeeded:
    
    var streak: Int {
        return 0
    }
    
    var tasksCompleted: Int {
        return 0
    }
}
