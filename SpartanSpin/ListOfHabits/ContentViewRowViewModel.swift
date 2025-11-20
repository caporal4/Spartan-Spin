//
//  ContentViewRowViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension ContentViewRow {
    class ViewModel: ObservableObject {
        var habit: Habit
        
        let units = Units()
        
        func convertToPlural(habit: Habit) -> String {
            if habit.habitUnit != "No Unit" {
                if habit.tasksNeeded == 1 {
                    return "\(Int(habit.tasksCompleted))/\(Int(habit.tasksNeeded)) \(habit.habitUnit)"
                } else {
                    if let index = units.list.firstIndex(of: habit.habitUnit) {
                        return "\(Int(habit.tasksCompleted))/\(Int(habit.tasksNeeded)) \(units.pluralList[index])"
                    }
                    return "\(Int(habit.tasksCompleted))/\(Int(habit.tasksNeeded)) \(habit.habitUnit)"
                }
            }
            return "\(Int(habit.tasksCompleted))/\(Int(habit.tasksNeeded))"
        }
        
        init(habit: Habit) {
            self.habit = habit
        }
    }
}
