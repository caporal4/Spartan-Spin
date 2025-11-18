//
//  HabitViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension HabitView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var habit: Habit
        
        @Published var showEditHabitView = false
        @Published var showingDeleteAlert = false
        
        func delete(_ habit: Habit) {
            persistenceController.removeReminders(for: habit)
            persistenceController.delete(habit)
            persistenceController.selectedHabit = nil
        }
        
        func streakSentence(_ habit: Habit) -> String {
            guard habit.streak > 0 else { return "" }

            switch habit.habitTimeline {
            case "Daily":
                return "\(habit.streak) Day Streak"
            case "Weekly":
                return "\(habit.streak) Week Streak"
            case "Monthly":
                return "\(habit.streak) Month Streak"
            default:
                return ""
            }
        }
        
        init(persistenceController: PersistenceController, habit: Habit) {
            self.persistenceController = persistenceController
            self.habit = habit
        }
    }
}
