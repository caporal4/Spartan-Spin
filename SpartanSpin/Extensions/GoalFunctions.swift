//
//  GoalFunctions.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/25/25.
//

import Foundation

extension Goal {
    // Used in ContentView
    func shouldResetStreak(_ today: Date) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        // If the streak has never increased, bail out so as to not reset everything
        guard let lastIncrease = lastStreakIncrease else { return false }
        
        let yesterday = returnYesterday(today)
        let lastWeek = returnLastWeek(today)
        let lastMonth = returnLastMonth(today)

        switch goalTimeline {
        case "Daily":
            // If last increase wasn't today or yesterday, reset the streak
            let streakIncreasedToday = calendar.isDate(lastIncrease, inSameDayAs: today)
            let streakIncreasedYesterday = calendar.isDate(lastIncrease, inSameDayAs: yesterday)
            if streakIncreasedToday || streakIncreasedYesterday {
                return false
            } else {
                return true
            }
        case "Weekly":
            // If last increase wasn't this week or last week, reset the streak
            let streakIncreasedThisWeek = calendar.isDate(lastIncrease, equalTo: today, toGranularity: .weekOfYear)
            let streakIncreasedLastWeek = calendar.isDate(
                lastIncrease,
                equalTo: lastWeek,
                toGranularity: .weekOfYear
            )
            if streakIncreasedThisWeek || streakIncreasedLastWeek {
                return false
            } else {
                return true
            }
        case "Monthly":
            // If last increase wasn't this month or last month, reset the streak
            let streakIncreasedThisMonth = calendar.isDate(lastIncrease, equalTo: today, toGranularity: .month)
            let streakIncreasedLastMonth = calendar.isDate(lastIncrease, equalTo: lastMonth, toGranularity: .month)
            if streakIncreasedThisMonth || streakIncreasedLastMonth {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
    
    private func returnYesterday(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return date }
        return yesterday
    }
    
    private func returnLastWeek(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: date) else { return date }
        return lastWeek
    }
    
    private func returnLastMonth(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: date) else { return date }
        return lastMonth
    }
    
    func shouldResetTasksForNewPeriod(_ today: Date) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        guard let lastReset = lastTaskReset else { return false }
        
        switch goalTimeline {
        case "Daily":
            // Reset tasks if it's a new day
            if calendar.isDate(lastReset, inSameDayAs: today) {
                return false
            } else {
                return true
            }
            
        case "Weekly":
            // Reset tasks if it's a new week
            if calendar.isDate(lastReset, equalTo: today, toGranularity: .weekOfYear) {
                return false
            } else {
                return true
            }
            
        case "Monthly":
            // Reset tasks if it's a new month
            if calendar.isDate(lastReset, equalTo: today, toGranularity: .month) {
                return false
            } else {
                return true
            }
            
        default:
            return true
        }
    }

    func resetStreak() {
        streak = 0
        tasksCompleted = 0
        lastStreakReset = Date.now
    }
    
    func resetTasks() {
        tasksCompleted = 0
        lastTaskReset = Date.now
    }
    
    // Used in GoalCounterView
    func doTask() {
        tasksCompleted += 1

        guard allowStreakUpdate() else { return }

        if tasksCompleted == tasksNeeded {
            streak += 1
            lastStreakIncrease = Date.now
        }
        
        try? self.managedObjectContext?.save()
    }
    
    func undoTask() {
        guard tasksCompleted > 0 else { return }
        if tasksCompleted == tasksNeeded {
            if streak > 0 {
                streak -= 1
            }
            lastStreakIncrease = nil
        }
        tasksCompleted -= 1
        try? self.managedObjectContext?.save()
    }
    
    private func allowStreakUpdate() -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let today = Date.now
        
        // If streak has never increased, return true to allow it to update
        guard let lastIncrease = lastStreakIncrease else { return true }
        
        switch goalTimeline {
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
    
    // Used in GoalView
    // oldValue is the value of tasksCompleted at the time the user opens the text field.
    func handleTextField(_ input: Double, _ oldValue: Double) {
        tasksCompleted = input
        
        if tasksCompleted < tasksNeeded && oldValue >= tasksNeeded {
            streak -= 1
            lastStreakIncrease = nil
            try? self.managedObjectContext?.save()
        } else if tasksCompleted >= tasksNeeded && oldValue < tasksNeeded {
            streak += 1
            lastStreakIncrease = Date.now
            try? self.managedObjectContext?.save()
        }
    }
    
    func streakSentence() -> String {
        guard streak > 0 else { return "" }

        switch goalTimeline {
        case "Daily":
            return "\(streak) Day Streak"
        case "Weekly":
            return "\(streak) Week Streak"
        case "Monthly":
            return "\(streak) Month Streak"
        default:
            return ""
        }
    }
    
    // Used in EditGoalViewModel
    func updateStreakFromTimeline(_ input: String) {
        if goalTimeline != input {
            if streak > 0 {
                streak = 1
                lastStreakReset = Date.now
                lastStreakIncrease = nil
            }
        }
    }
}
