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
            guard habit.unit != "No Unit" else { return "" }
            
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
            let oldValue = habit.tasksCompleted
            
            guard let convertedNumber = Double(numberInput) else {
                showError = true
                return
            }
            guard convertedNumber >= 0 else {
                showError = true
                return
            }
            
            habit.tasksCompleted = convertedNumber
            
            if habit.tasksCompleted < habit.tasksNeeded && oldValue >= habit.tasksNeeded {
                habit.streak -= 1
                habit.lastStreakIncrease = nil
                persistenceController.save()
            } else if habit.tasksCompleted >= habit.tasksNeeded && oldValue < habit.tasksNeeded {
                habit.streak += 1
                habit.lastStreakIncrease = Date.now
                persistenceController.save()
            }
            
            numberInput = ""
        }
        
        func invalidNumber() {
            showPopup = true
            numberInput = ""
        }
        
        func doTask() {
            habit.tasksCompleted += 1

            guard allowStreakUpdate() else { return }

            if habit.tasksCompleted == habit.tasksNeeded {
                habit.streak += 1
                habit.lastStreakIncrease = Date.now
            }
            
            persistenceController.save()
        }
        
        func undoTask() {
            guard habit.tasksCompleted > 0 else { return }
            if habit.tasksCompleted == habit.tasksNeeded {
                habit.streak -= 1
                habit.lastStreakIncrease = nil
            }
            habit.tasksCompleted -= 1
            persistenceController.save()
        }
        
        private func allowStreakUpdate() -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            let today = Date.now + (86400 * 0)
            
            // If streak has never increased, return true to allow it to update
            guard let lastIncrease = habit.lastStreakIncrease else { return true }
            
            switch habit.habitTimeline {
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
        
        init(persistenceController: PersistenceController, habit: Habit) {
            self.persistenceController = persistenceController
            self.habit = habit
        }
    }
}
