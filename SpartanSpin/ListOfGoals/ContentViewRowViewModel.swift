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
        
        func convertToPlural(goal: Goal) -> String {
            if goal.goalUnit != "No Unit" {
                if goal.tasksNeeded == 1 {
                    return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(goal.goalUnit)"
                } else {
                    if let index = units.list.firstIndex(of: goal.goalUnit) {
                        return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(units.pluralList[index])"
                    }
                    return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded)) \(goal.goalUnit)"
                }
            }
            return "\(Int(goal.tasksCompleted))/\(Int(goal.tasksNeeded))"
        }
        
        init(goal: Goal) {
            self.goal = goal
        }
    }
}
