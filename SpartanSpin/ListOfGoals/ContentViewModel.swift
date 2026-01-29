//
//  ContentViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Combine
import CoreData
import Foundation
import SwiftUI

extension ContentView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        
        @Published var newGoal = false
        @Published var newGoalMonthlyMove = false
        
        private let moveService: MonthlyMoveService
        private let moveCache: MonthlyMoveCache
        
        @Published var currentMove: MonthlyMove?
        @Published var isLoadingMove = false
        @Published var failedToLoad = false
        @Published var multipleGoalsWithMonthlyMove = false
        
        init(
            persistenceController: PersistenceController,
            moveService: MonthlyMoveService = MonthlyMoveAPI(),
            moveCache: MonthlyMoveCache = MonthlyMoveCache()
        ) {
            self.persistenceController = persistenceController
            self.moveService = moveService
            self.moveCache = moveCache
        }
        
        @MainActor
        func fetchMoveOfTheMonth() async {
            if CommandLine.arguments.contains("-forceMonthlyMove"),
               let forceIndex = CommandLine.arguments.firstIndex(of: "-forceMonthlyMove"),
               forceIndex + 1 < CommandLine.arguments.count {
                
                let forcedMoveName = CommandLine.arguments[forceIndex + 1]
                let forcedMoveUnit = CommandLine.arguments[forceIndex + 2]
                
                let currentDate = Date()
                let calendar = Calendar.current
                let month = calendar.component(.month, from: currentDate)
                let year = calendar.component(.year, from: currentDate)
                
                // Get month name
                let monthName = calendar.monthSymbols[month - 1] // January = index 0
                
                // fix
                let testMove = MonthlyMove(
                    move: forcedMoveName,
                    unit: forcedMoveUnit,
                    month: monthName,
                    year: year
                )
                
                currentMove = testMove
                return
            }
            isLoadingMove = true
            
            do {
                if let move = moveCache.getCached() {
                    currentMove = move
                    isLoadingMove = false
                    failedToLoad = false
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
        
        func showNewGoalView() {
            newGoal = true
        }
        
        func showNewGoalViewMonthlyMove() {
            newGoalMonthlyMove = true
        }
        
        func showMonthlyMoveList() {
            multipleGoalsWithMonthlyMove = true
        }
        
        func swipeToDelete(goals: [Goal], _ offsets: IndexSet) {
            for offset in offsets {
                let item = goals[offset]
                persistenceController.removeReminders(for: item)
                persistenceController.delete(item)
                persistenceController.save()
            }
        }

        func checkAndResetStreaks(goals: [Goal]) {
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
