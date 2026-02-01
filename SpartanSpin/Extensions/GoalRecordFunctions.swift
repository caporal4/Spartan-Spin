//
//  GoalRecordFunctions.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/31/26.
//

import Foundation

extension GoalRecord {
    func createFraction() -> String {
        guard let index = Units().list.firstIndex(of: self.recordUnit) else {
            return "\(Int(self.tasksCompleted))/\(Int(self.tasksNeeded)) \(self.recordUnit)"
        }
        guard self.recordUnit != "No Unit" else {
            return "\(Int(self.tasksCompleted))/\(Int(self.tasksNeeded))"
        }
        if self.tasksNeeded == 1 {
            return "\(Int(self.tasksCompleted))/\(Int(self.tasksNeeded)) \(self.recordUnit)"
        } else {
            return "\(Int(self.tasksCompleted))/\(Int(self.tasksNeeded)) \(Units().pluralList[index])"
        }
    }
    
    func streakSentence() -> String {
        guard streak > 0 else { return "" }

        switch recordTimeline {
        case "Daily":
            return "\(streak) Day Streak"
        case "Weekly":
            return "\(streak) Week Streak"
        case "Monthly":
            return "\(streak) Month Streak"
        default:
            return ""
        }
    }
}
