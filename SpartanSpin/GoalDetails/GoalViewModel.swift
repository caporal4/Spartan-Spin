//
//  GoalViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import Foundation

extension GoalView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var goal: Goal
        
        @Published var showEditGoalView = false
        @Published var showingDeleteAlert = false
        
        func delete(_ goal: Goal) {
            let today = Calendar.current.startOfDay(for: Date())
            let context = persistenceController.container.viewContext
            
            let fetchRequest: NSFetchRequest<GoalRecord> = GoalRecord.fetchRequest()
            guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return }
            
            fetchRequest.predicate = NSPredicate(
                format: "goal == %@ AND date >= %@ AND date < %@",
                goal,
                today as NSDate,
                endOfDay as NSDate
            )
            
            if let todayRecords = try? context.fetch(fetchRequest) {
                for record in todayRecords {
                    context.delete(record)
                }
            }
            
            persistenceController.removeReminders(for: goal)
            persistenceController.delete(goal)
        }
        
        init(
            persistenceController: PersistenceController,
            goal: Goal
        ) {
            self.persistenceController = persistenceController
            self.goal = goal
        }
    }
}
