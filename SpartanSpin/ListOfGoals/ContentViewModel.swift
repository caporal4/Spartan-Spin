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
        @Published var newGoalMonthlyMove = false
        @Published var monthlyMove = "Push-ups"
        
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
        
        func showNewGoalViewMonthlyMove() {
            newGoalMonthlyMove = true
        }
        
        func dailySwipeToDelete(_ offsets: IndexSet) {
            let dailyGoals = goals.dailyGoals
            for offset in offsets {
                let item = dailyGoals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func weeklySwipeToDelete(_ offsets: IndexSet) {
            let weeklyGoals = goals.weeklyGoals
            for offset in offsets {
                let item = weeklyGoals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }
        
        func monthlySwipeToDelete(_ offsets: IndexSet) {
            let monthlyGoals = goals.monthlyGoals
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

        func checkAndResetStreaks() {
            let date = Date.now
            
            for goal in goals {
                if goal.shouldResetStreak(date) {
                // If true, this means the streak wasn't met today or in the last period, so it resets
                    goal.resetStreak()
                
                } else if goal.shouldResetTasksForNewPeriod(date) {
                    goal.resetTasks()
                }
            }
        }
    }
}
