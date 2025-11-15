//
//  HabitCounterViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension HabitCounterView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var habit: Habit
        
        let units = Units()
        
        @Published var showPopup = false
        @Published var numberInput = ""
        @Published var showError = false
        @Published var errorMessage = "Enter a valid number."
        
        var convertedNumber = 0
        
        func convertToPlural(_ habit: Habit) -> String {
            if habit.tasksNeeded == 1 {
                return habit.habitUnit
            } else {
                if let index = units.list.firstIndex(of: habit.habitUnit) {
                    if habit.tasksNeeded == 1 {
                        return units.list[index]
                    } else {
                        return units.pluralList[index]
                    }
                }
                return habit.habitUnit
            }
        }
        
        func enterAmount() {
            showPopup = true
        }
        
        func updateTasks() {
            guard let convertedNumber = Int16(numberInput) else {
                showError = true
                return
            }
            guard convertedNumber >= 0 else {
                showError = true
                return
            }
            
            habit.tasksCompleted = convertedNumber
            
            if habit.tasksCompleted < habit.tasksNeeded {
                habit.streak -= 1
            } else if habit.tasksCompleted >= habit.tasksNeeded {
                habit.streak += 1
            }
            
            numberInput = ""
        }
        
        func invalidNumber() {
            showPopup = true
            numberInput = ""
        }
        
        func doTask() {
            habit.tasksCompleted += 1
            if habit.tasksCompleted == habit.tasksNeeded {
                habit.streak += 1
            }
            persistenceController.save()
        }
        
        func undoTask() {
            guard habit.tasksCompleted > 0 else { return }
            if habit.tasksCompleted == habit.tasksNeeded {
                habit.streak -= 1
            }
            habit.tasksCompleted -= 1
            persistenceController.save()
        }
        
        init(persistenceController: PersistenceController, habit: Habit) {
            self.persistenceController = persistenceController
            self.habit = habit
        }
    }
}
