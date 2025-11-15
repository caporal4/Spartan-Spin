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
        
        init(persistenceController: PersistenceController, habit: Habit) {
            self.persistenceController = persistenceController
            self.habit = habit
        }
    }
}
