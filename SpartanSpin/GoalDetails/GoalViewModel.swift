//
//  GoalViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension GoalView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var goal: Goal
        
        @Published var showEditGoalView = false
        @Published var showingDeleteAlert = false
        
        func delete(_ goal: Goal) {
            persistenceController.removeReminders(for: goal)
            persistenceController.delete(goal)
            persistenceController.selectedGoal = nil
        }
        
        init(persistenceController: PersistenceController, goal: Goal) {
            self.persistenceController = persistenceController
            self.goal = goal
        }
    }
}
