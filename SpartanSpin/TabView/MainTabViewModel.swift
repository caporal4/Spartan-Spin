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
            goalRecordsController.delegate = self
            
            do {
                // Add error handling
                try goalsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
                
                // Add error handling
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
            let now = Date.now
            for goal in goals {
                if goal.doesRecordExist(
                    record: goal.findRecord(
                        for: now,
                        records: goalRecords,
                        timeline: goal.goalTimeline
                    )
                ) {
                    continue
                }
                
                goal.createRecord(
                    on: now,
                    context: persistenceController.container.viewContext
                )
            }
        }
        
        func createHistoricRecords() {
            let now = Date.now
            
            for goal in goals {
                guard let lastRecordDate = findLastRecordDate(for: goal) else {
                    continue
                }
                
                createMissingRecords(for: goal, from: lastRecordDate, until: now)
            }
        }

        private func findLastRecordDate(for goal: Goal) -> Date? {
            let goalRecordsForThisGoal = goalRecords.filter { record in
                record.goal?.objectID == goal.objectID
            }
            
            let lastRecord = goalRecordsForThisGoal.max(by: {
                ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast)
            })
            
            return lastRecord?.date
        }

        private func createMissingRecords(for goal: Goal, from startDate: Date, until endDate: Date) {
            let calendar = Calendar.current
            
            guard var currentDate = getNextPeriodDate(
                after: startDate,
                for: goal.goalTimeline,
                calendar: calendar
            ) else {
                return
            }
            
            while currentDate <= endDate {
                if !goal.doesRecordExist(
                    record: goal.findRecord(
                        for: currentDate,
                        records: goalRecords,
                        timeline: goal.goalTimeline
                    )
                ) {
                    goal.createHistoricRecord(
                        on: currentDate,
                        context: persistenceController.container.viewContext
                    )
                }
                
                guard let nextDate = getNextPeriodDate(
                    after: currentDate,
                    for: goal.goalTimeline,
                    calendar: calendar
                ) else {
                    break
                }
                currentDate = nextDate
            }
        }

        private func getNextPeriodDate(after date: Date, for timeline: String, calendar: Calendar) -> Date? {
            switch timeline {
            case "Daily":
                return calendar.date(byAdding: .day, value: 1, to: date)
            case "Weekly":
                return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
            case "Monthly":
                return calendar.date(byAdding: .month, value: 1, to: date)
            default:
                return nil
            }
        }
        
        // Add error handling
        func calculateNewDate(of date: Date, amount: Int) {
            guard let newMonth =  Calendar.current.date(byAdding: .month, value: amount, to: date) else { return }
            displayedMonth = newMonth
        }
    }
}
