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
        
        private let habitsController: NSFetchedResultsController<Habit>
        
        @Published var habits = [Habit]()
        @Published var newHabit = false
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
            
            let request = Habit.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.title, ascending: true)]
            
            habitsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            super.init()
            
            habitsController.delegate = self
            
            do {
                try habitsController.performFetch()
                habits = habitsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch habits")
            }
        }
        
        func reloadData() {
            let request = Habit.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.title, ascending: true)]
            
            let newController: NSFetchedResultsController<Habit>
            newController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            do {
                try newController.performFetch()
                habits = newController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch habits")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newHabits = controller.fetchedObjects as? [Habit] {
                habits = newHabits
            }
        }
        
        func showNewHabitView() {
            newHabit = true
        }
        
        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = habits[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func removeAllNotifications() {
            for habit in habits {
                persistenceController.removeReminders(for: habit)
            }
        }
        
        private func shouldResetStreak(_ habit: Habit, _ today: Date) -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            // If the streak has never increased, bail out so as to not reset everything
            guard let lastIncrease = habit.lastStreakIncrease else { return false }
            
            guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today) else { return false }
            
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: today) else { return false }

            switch habit.habitTimeline {
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
        
        private func shouldResetTasksForNewPeriod(_ habit: Habit, _ today: Date) -> Bool {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            guard let lastReset = habit.lastTaskReset else { return false }
            
            switch habit.habitTimeline {
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
            
            for habit in habits {
                if shouldResetStreak(habit, date) {
                // If true, this means the streak wasn't met today or in the last period, so it resets
                    habit.streak = 0
                    habit.tasksCompleted = 0
                    habit.lastStreakReset = Date.now
                    print("\(habit.habitTitle) everything reset")
                
                } else if shouldResetTasksForNewPeriod(habit, date) {
                    // If true, the streak was met today so we don't want to reset the streak value
                    // THIS IS BROKEN, it will check the same day. So it thinks it needs to reset values
                    habit.tasksCompleted = 0
                    print("\(habit.habitTitle) tasks reset")
                }
            }
        }
    }
}
