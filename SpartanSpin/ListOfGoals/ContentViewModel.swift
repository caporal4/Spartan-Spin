//
//  ContentViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import Foundation
import SwiftUI

extension ContentView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var persistenceController: PersistenceController
        
        private let goalsController: NSFetchedResultsController<Goal>
        
        @Published var goals = [Goal]()
        @Published var newGoal = false
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
            
            let request = Goal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.title, ascending: true)]
            
            goalsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            super.init()
            
            goalsController.delegate = self
            
            do {
                try goalsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch goals")
            }
        }
        
        func reloadData() {
            let request = Goal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.title, ascending: true)]
            
            let newController: NSFetchedResultsController<Goal>
            newController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            do {
                try newController.performFetch()
                goals = newController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch goals")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newGoals = controller.fetchedObjects as? [Goal] {
                goals = newGoals
            }
        }
        
        func showNewGoalView() {
            newGoal = true
        }
        
        func dailyDelete(_ offsets: IndexSet) {
            let dailyGoals = dailyGoals(goals)
            for offset in offsets {
                let item = dailyGoals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func weeklyDelete(_ offsets: IndexSet) {
            let weeklyGoals = weeklyGoals(goals)
            for offset in offsets {
                let item = weeklyGoals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func monthlyDelete(_ offsets: IndexSet) {
            let monthlyGoals = monthlyGoals(goals)
            for offset in offsets {
                let item = monthlyGoals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func removeAllNotifications() {
            for goal in goals {
                persistenceController.removeReminders(for: goal)
            }
        }
        
        func dailyGoals(_ goals: [Goal]) -> [Goal] {
            var dailyGoals = [Goal]()
            for goal in goals where goal.timeline == "Daily" {
                dailyGoals.append(goal)
            }
            return dailyGoals
        }
        
        func weeklyGoals(_ goals: [Goal]) -> [Goal] {
            var weeklyGoals = [Goal]()
            for goal in goals where goal.timeline == "Weekly" {
                weeklyGoals.append(goal)
            }
            return weeklyGoals
        }
        
        func monthlyGoals(_ goals: [Goal]) -> [Goal] {
            var monthlyGoals = [Goal]()
            for goal in goals where goal.timeline == "Monthly" {
                monthlyGoals.append(goal)
            }
            return monthlyGoals
        }
        
        private func shouldResetStreak(_ goal: Goal, _ today: Date) -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            // If the streak has never increased, bail out so as to not reset everything
            guard let lastIncrease = goal.lastStreakIncrease else { return false }
            
            guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today) else { return false }
            
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: today) else { return false }

            switch goal.goalTimeline {
            case "Daily":
                // If last increase wasn't today or yesterday, reset the streak
                let streakIncreasedToday = calendar.isDate(lastIncrease, inSameDayAs: today)
                let streakIncreasedYesterday = calendar.isDateInYesterday(lastIncrease)
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
        
        private func shouldResetTasksForNewPeriod(_ goal: Goal, _ today: Date) -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            guard let lastReset = goal.lastTaskReset else { return false }
            
            switch goal.goalTimeline {
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

        func checkAndResetStreaks() {
            let date = Date.now + (86400 * 0)
            
            for goal in goals {
                if shouldResetStreak(goal, date) {
                // If true, this means the streak wasn't met today or in the last period, so it resets
                    goal.streak = 0
                    goal.tasksCompleted = 0
                    goal.lastStreakReset = Date.now
                
                } else if shouldResetTasksForNewPeriod(goal, date) {
                    goal.tasksCompleted = 0
                }
            }
        }
    }
}
