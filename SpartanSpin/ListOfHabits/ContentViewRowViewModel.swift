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
                    return "\(habit.tasksCompleted)/\(habit.tasksNeeded) \(habit.habitUnit)"
                } else {
                    if let index = units.list.firstIndex(of: habit.habitUnit) {
                        return "\(habit.tasksCompleted)/\(habit.tasksNeeded) \(units.pluralList[index])"
                    }
                    return "\(habit.tasksCompleted)/\(habit.tasksNeeded) \(habit.habitUnit)"
                }
            }
            return "\(habit.tasksCompleted)/\(habit.tasksNeeded)"
        }
        
        init(habit: Habit) {
            self.habit = habit
        }
    }
}
