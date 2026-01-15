//
//  PersistenceController-GoalRecord.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/7/26.
//

import CoreData
import Foundation

extension Goal {
    func updateRecord(_ record: GoalRecord) {
        record.title = self.title
        record.timeline = self.timeline
        record.unit = self.unit
        record.tasksCompleted = self.tasksCompleted
        record.tasksNeeded = self.tasksNeeded
        record.streak = self.streak
        try? managedObjectContext?.save()
    }
    
    func createOrFindRecord(
        context: NSManagedObjectContext,
        records: [GoalRecord], goal: Goal
    ) -> (GoalRecord, [GoalRecord]) {
        var updatedRecords = records
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if record exists for today
        if let existing = findRecord(for: today, records: records, goal: goal) {
            print("Old Record found")
            return (existing, records)
        }
        print("New record created")
        
        // Create new record for today
        let record = GoalRecord(context: context)
        record.date = today
        record.goal = goal
        updateRecord(record)
        updatedRecords.append(record)
        try? managedObjectContext?.save()
        
        return (record, updatedRecords)
    }
    
    private func findRecord(for date: Date, records: [GoalRecord], goal: Goal) -> GoalRecord? {
        let calendar = Calendar.current
        
        return records.first { record in
            guard record.goal?.objectID == goal.objectID else {return false }
            guard let recordDate = record.date else { return false }
            return calendar.isDate(recordDate, inSameDayAs: date)
        }
    }
}
