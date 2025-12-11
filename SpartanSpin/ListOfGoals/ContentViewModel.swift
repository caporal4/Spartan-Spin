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
        
        private let moveService: MonthlyMoveService
        private let moveCache: MonthlyMoveCache
        
        @Published var currentMove: MonthlyMove?
        @Published var isLoadingMove = false
        @Published var failedToLoad = false
        
        init(
            persistenceController: PersistenceController,
            moveService: MonthlyMoveService = MonthlyMoveAPI(),
            moveCache: MonthlyMoveCache = MonthlyMoveCache()
        ) {
            self.persistenceController = persistenceController
            self.moveService = moveService
            self.moveCache = moveCache
            
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
        
        @MainActor
        func fetchMoveOfTheMonth() async {
            isLoadingMove = true
            
            do {
                if let move = moveCache.getCached() {
                    currentMove = move
                    isLoadingMove = false
                    failedToLoad = false
                    print("cached item retrieved")
                    return
                }
                let moves = try await moveService.fetchMoves()
                let calendar = Calendar.current
                let currentMonth = calendar.component(.month, from: Date())
                let currentYear = calendar.component(.year, from: Date())
                
                currentMove = moves.first { move in
                    let monthName = calendar.monthSymbols[currentMonth - 1]
                    return move.month == monthName && move.year == currentYear
                }
                failedToLoad = false
                
                guard let currentMove = currentMove else { return }
                moveCache.cache(currentMove)
            } catch {
                failedToLoad = true
                isLoadingMove = false
                print("Move fetch error: \(error)")
            }
            
            isLoadingMove = false
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
