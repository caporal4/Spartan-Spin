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
    func findRecord(for date: Date, records: [GoalRecord], timeline: String) -> GoalRecord? {
        var calendar: Calendar {
            var cal = Calendar.current
            cal.firstWeekday = 2  // Monday
            return cal
        }

        let currentRecord = records.first { record in
            guard record.goal?.objectID == self.objectID else { return false }
            guard let recordDate = record.date else { return false }
            
            switch timeline {
            case "Daily":
                return calendar.isDate(recordDate, inSameDayAs: date)
            case "Weekly":
                return calendar.isDate(recordDate, equalTo: date, toGranularity: .weekOfYear)
            case "Monthly":
                return calendar.isDate(recordDate, equalTo: date, toGranularity: .month)
            default:
                return false
            }
        }
        
        return currentRecord
    }
    
    func createRecord(on today: Date, context: NSManagedObjectContext) {
        let record = GoalRecord(context: context)
        record.date = today
        record.goal = self
        fullyUpdateRecord(record)
    }
    
    func createHistoricRecord(on today: Date, context: NSManagedObjectContext) {
        let record = GoalRecord(context: context)
        record.date = today
        record.goal = self
        record.title = self.title
        record.timeline = self.timeline
        record.unit = self.unit
        record.tasksCompleted = 0
        record.tasksNeeded = self.tasksNeeded
        record.streak = 0
    }
    
    func updateRecord(_ record: GoalRecord) {
        record.tasksCompleted = self.tasksCompleted

        var calendar = Calendar.current
        calendar.firstWeekday = 2

        if let lastIncrease = self.lastStreakIncrease {
            let streakIncreasedThisPeriod: Bool
            switch self.goalTimeline {
            case "Daily":   streakIncreasedThisPeriod = calendar.isDate(lastIncrease, inSameDayAs: Date.now)
            case "Weekly":  streakIncreasedThisPeriod = calendar.isDate(
                lastIncrease,
                equalTo: Date.now,
                toGranularity: .weekOfYear
            )
            case "Monthly": streakIncreasedThisPeriod = calendar.isDate(
                lastIncrease,
                equalTo: Date.now,
                toGranularity: .month
            )
            default:        streakIncreasedThisPeriod = false
            }

            if streakIncreasedThisPeriod {
                record.streak = self.streak
            } else if self.streak < record.streak {
                record.streak = 0
            }
        } else if self.streak < record.streak {
            // lastStreakIncrease is nil, meaning undoTask() cleared it
            record.streak = 0
        }

        save()
    }
    
    func fullyUpdateRecord(_ record: GoalRecord) {
        record.title = self.title
        record.timeline = self.timeline
        record.unit = self.unit
        record.tasksCompleted = self.tasksCompleted
        record.tasksNeeded = self.tasksNeeded
        record.streak = 0
        save()
    }
}
