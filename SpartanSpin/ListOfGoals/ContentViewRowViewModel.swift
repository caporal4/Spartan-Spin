//
//  ContentViewRowViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension ContentViewRow {
    class ViewModel: ObservableObject {
        var goal: Goal
        
        let units = Units()
        
        func createFraction(goal: Goal) -> String {
            guard let index = units.list.firstIndex(of: goal.goalUnit) else {
                return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(goal.goalUnit)"
            }
            guard goal.goalUnit != "No Unit" else {
                return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded))"
            }
            if goal.tasksNeeded == 1 {
                return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(goal.goalUnit)"
            } else {
                return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(units.pluralList[index])"
            }
        }
        
        init(goal: Goal) {
            self.goal = goal
        }
    }
}
