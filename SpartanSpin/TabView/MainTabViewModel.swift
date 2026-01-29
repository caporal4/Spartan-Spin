//
//  MainTabViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import CoreData
import Foundation

@MainActor
extension MainTabView {
    class ViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
        var persistenceController: PersistenceController
        
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        private let goalsController: NSFetchedResultsController<Goal>
        private let goalRecordsController: NSFetchedResultsController<GoalRecord>

        @Published var goals = [Goal]()
        @Published var goalRecords = [GoalRecord]()

        @Published var selectedDate: DateComponents?
        @Published var displayedMonth: Date = Date()

        var calendar: Calendar = .current
        var monthTitle: String {
            displayedMonth.formatted(.dateTime.month(.wide).year())
        }
        
        @Published var showingDetail = false
        @Published var showingMonthPicker = false
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
            
            let goalRequest = Goal.fetchRequest()
            goalRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.title, ascending: true)]
            
            let goalRecordsRequest = GoalRecord.fetchRequest()
            goalRecordsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GoalRecord.date, ascending: true)]
            
            goalsController = NSFetchedResultsController(
                fetchRequest: goalRequest,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            goalRecordsController = NSFetchedResultsController(
                fetchRequest: goalRecordsRequest,
                managedObjectContext: persistenceController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            super.init()
            
            goalsController.delegate = self
            
            do {
                try goalsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
                try goalRecordsController.performFetch()
                goalRecords = goalRecordsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch goals")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newGoals = controller.fetchedObjects as? [Goal] {
                goals = newGoals
            }
            if let newGoalRecords = controller.fetchedObjects as? [GoalRecord] {
                goalRecords = newGoalRecords
            }
        }
        
        func createNewRecords() {
            for goal in goals {
                if goal.findRecord(for: Date.now, records: goalRecords) {
                    continue
                }
                goalRecords.append(goal.createRecord(
                    on: Date.now,
                    context: persistenceController.container.viewContext
                ))
            }
        }
        
        // Add error handling
        func calculateNewDate(of date: Date, amount: Int) {
            guard let newMonth =  Calendar.current.date(byAdding: .month, value: amount, to: date) else { return }
            displayedMonth = newMonth
        }
    }
}
