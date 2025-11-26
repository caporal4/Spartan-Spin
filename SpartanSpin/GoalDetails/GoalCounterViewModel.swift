//
//  GoalCounterViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

extension GoalCounterView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var goal: Goal
        
        let units = Units()
        
        @Published var showPopup = false
        @Published var numberInput = ""
        @Published var showError = false
        @Published var errorMessage = "Enter a valid number."
        
        var convertedNumber = 0
        
        func enterAmount() {
            showPopup = true
        }
        
        func updateTasksFromTextField() {
            let oldValue = goal.tasksCompleted
            
            guard let convertedNumber = Double(numberInput) else {
                showError = true
                return
            }
            guard convertedNumber >= 0 else {
                showError = true
                return
            }
            
            goal.handleTextField(convertedNumber, oldValue)

            numberInput = ""
        }
        
        func invalidNumber() {
            showPopup = true
            numberInput = ""
        }
        
        init(persistenceController: PersistenceController, goal: Goal) {
            self.persistenceController = persistenceController
            self.goal = goal
        }
    }
}
