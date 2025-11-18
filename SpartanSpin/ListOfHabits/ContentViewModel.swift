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
        
        private func shouldResetHabit(_ habit: Habit, currentDate: Date) -> Bool {
            guard let lastReset = habit.lastStreakReset else { return false }
            
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            switch habit.habitTimeline {
            case "Daily":
                return !calendar.isDate(currentDate, inSameDayAs: lastReset)
            case "Weekly":
                let currentWeek = calendar.component(.weekOfYear, from: currentDate)
                let lastWeek = calendar.component(.weekOfYear, from: lastReset)
                let currentYear = calendar.component(.year, from: currentDate)
                let lastYear = calendar.component(.year, from: lastReset)
                return currentWeek != lastWeek || currentYear != lastYear
            case "Monthly":
                let currentMonth = calendar.component(.month, from: currentDate)
                let lastMonth = calendar.component(.month, from: lastReset)
                let currentYear = calendar.component(.year, from: currentDate)
                let lastYear = calendar.component(.year, from: lastReset)
                return currentMonth != lastMonth || currentYear != lastYear
            case "Yearly":
                let currentYear = calendar.component(.year, from: currentDate)
                let lastYear = calendar.component(.year, from: lastReset)
                return currentYear != lastYear
            default:
                return false
            }
        }

        func launchApp() {
            let currentDate = Date.now + (86400 * 2)            
            for habit in habits where shouldResetHabit(habit, currentDate: currentDate) {
                if habit.tasksCompleted < habit.tasksNeeded {
                    habit.streak = 0
                }
                habit.tasksCompleted = 0
                habit.lastStreakReset = currentDate
            }
        }
    }
}
