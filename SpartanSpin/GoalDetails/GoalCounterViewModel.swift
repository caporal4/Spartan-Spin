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
        
        func convertToPlural(_ goal: Goal) -> String {
            guard goal.unit != "No Unit" else { return "" }
            
            if goal.tasksNeeded == 1 {
                return goal.goalUnit
            } else {
                if let index = units.list.firstIndex(of: goal.goalUnit) {
                    if goal.tasksNeeded == 1 {
                        return units.list[index]
                    } else {
                        return units.pluralList[index]
                    }
                }
                return goal.goalUnit
            }
        }
        
        func enterAmount() {
            showPopup = true
        }
        
        func updateTasks() {
            let oldValue = goal.tasksCompleted
            
            guard let convertedNumber = Double(numberInput) else {
                showError = true
                return
            }
            guard convertedNumber >= 0 else {
                showError = true
                return
            }
            
            goal.tasksCompleted = convertedNumber
            
            if goal.tasksCompleted < goal.tasksNeeded && oldValue >= goal.tasksNeeded {
                goal.streak -= 1
                goal.lastStreakIncrease = nil
                persistenceController.save()
            } else if goal.tasksCompleted >= goal.tasksNeeded && oldValue < goal.tasksNeeded {
                goal.streak += 1
                goal.lastStreakIncrease = Date.now
                persistenceController.save()
            }
            
            numberInput = ""
        }
        
        func invalidNumber() {
            showPopup = true
            numberInput = ""
        }
        
        func doTask() {
            goal.tasksCompleted += 1

            guard allowStreakUpdate() else { return }

            if goal.tasksCompleted == goal.tasksNeeded {
                goal.streak += 1
                goal.lastStreakIncrease = Date.now
            }
            
            persistenceController.save()
        }
        
        func undoTask() {
            guard goal.tasksCompleted > 0 else { return }
            if goal.tasksCompleted == goal.tasksNeeded {
                if goal.streak > 0 {
                    goal.streak -= 1
                }
                goal.lastStreakIncrease = nil
            }
            goal.tasksCompleted -= 1
            persistenceController.save()
        }
        
        private func allowStreakUpdate() -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            let today = Date.now + (86400 * 0)
            
            // If streak has never increased, return true to allow it to update
            guard let lastIncrease = goal.lastStreakIncrease else { return true }
            
            switch goal.goalTimeline {
            case "Daily":
                // If streak has already increased once today (streakIncreasedToday = true),
                // don't let it happen again (allowStreakUpdate() = false)
                let streakIncreasedToday = calendar.isDate(lastIncrease, inSameDayAs: today)
                if streakIncreasedToday {
                    return false
                } else {
                    return true
                }
            case "Weekly":
                // If streak has already increased once this week, don't let it happen again
                let streakIncreasedThisWeek = calendar.isDate(lastIncrease, equalTo: today, toGranularity: .weekOfYear)
                return !streakIncreasedThisWeek
            case "Monthly":
                // If streak has already increased once this month, don't let it happen again
                let streakIncreasedThisMonth = calendar.isDate(lastIncrease, equalTo: today, toGranularity: .month)
                return !streakIncreasedThisMonth
            default:
                return false
            }
        }
        
        init(persistenceController: PersistenceController, goal: Goal) {
            self.persistenceController = persistenceController
            self.goal = goal
        }
    }
}
