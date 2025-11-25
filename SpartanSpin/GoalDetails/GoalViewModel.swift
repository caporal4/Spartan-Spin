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
        
        func streakSentence(_ goal: Goal) -> String {
            guard goal.streak > 0 else { return "" }

            switch goal.goalTimeline {
            case "Daily":
                return "\(goal.streak) Day Streak"
            case "Weekly":
                return "\(goal.streak) Week Streak"
            case "Monthly":
                return "\(goal.streak) Month Streak"
            default:
                return ""
            }
        }
        
        init(persistenceController: PersistenceController, goal: Goal) {
            self.persistenceController = persistenceController
            self.goal = goal
        }
    }
}
