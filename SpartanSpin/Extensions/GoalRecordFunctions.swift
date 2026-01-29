//
//  PersistenceController-GoalRecord.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/7/26.
//

import CoreData
import Foundation

// Consider not passing in a list of records anywhere. Update the list directly in the viewmodel.

extension Goal {
    func findRecord(for date: Date, records: [GoalRecord]) -> Bool {
        let calendar = Calendar.current
        
        // Look for a record
        let currentRecord = records.first { record in
            guard record.goal?.objectID == self.objectID else { return false }
            guard let recordDate = record.date else { return false }
            return calendar.isDate(recordDate, inSameDayAs: date)
        }
        
        // If a record was found, return true
        if currentRecord != nil {
            return true
        }
        
        // If a record wasn't found, return false
        return false
    }
    
    func createRecord(on today: Date, context: NSManagedObjectContext) -> GoalRecord {
        let record = GoalRecord(context: context)
        record.date = today
        record.goal = self
        fullyUpdateRecord(record)
        return record
    }
    
    func updateRecord(_ record: GoalRecord) {
        record.tasksCompleted = self.tasksCompleted
        record.streak = self.streak
    }
    
    // Add in places where records are loaded for the day
    func fullyUpdateRecord(_ record: GoalRecord) {
        record.title = self.title
        record.timeline = self.timeline
        record.unit = self.unit
        record.tasksCompleted = self.tasksCompleted
        record.tasksNeeded = self.tasksNeeded
        record.streak = self.streak
    }
}
