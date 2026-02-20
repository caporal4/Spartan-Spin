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
        
        @Published var selectedTab = 0
        @Published var previousTab = 0

        var calendar: Calendar {
            var cal = Calendar.current
            cal.firstWeekday = 2  // Monday
            return cal
        }
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
                try goalsController.performFetch()
                goals = goalsController.fetchedObjects ?? []
                
                try goalRecordsController.performFetch()
                goalRecords = goalRecordsController.fetchedObjects ?? []
            } catch {
                assertionFailure("Core Data fetch failed: \(error)")
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
        
        func createNewRecords(for date: Date = Date.now) {
            for goal in goals where goal.findRecord(
                for: date,
                records: goalRecords,
                timeline: goal.goalTimeline
            ) == nil {
                goal.createRecord(
                    on: date,
                    context: persistenceController.container.viewContext
                )
            }
        }
        
        func createHistoricRecords(for date: Date = Date.now) {
            for goal in goals {
                guard let lastRecordDate = findLastRecordDate(for: goal) else {
                    continue
                }
                
                createMissingRecords(for: goal, from: lastRecordDate, until: date)
            }
            persistenceController.save()
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
            
            while currentDate < endDate {
                if goal.findRecord(
                        for: currentDate,
                        records: goalRecords,
                        timeline: goal.goalTimeline
                    ) == nil {
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
                assertionFailure("Unexpected timeline value: \(timeline)")
                return nil
            }
        }
        
        func calculateNewDate(amount: Int) {
            guard let newMonth =  Calendar.current.date(
                byAdding: .month,
                value: amount,
                to: displayedMonth
            ) else { return }
            displayedMonth = newMonth
        }
    }
}
