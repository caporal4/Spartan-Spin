//
//  EditGoalViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation
import SwiftUI

extension EditGoalView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var goal: Goal
        
        let units = Units()
        let timelines = Timelines()
        
        let originalTasksNeeded: Double
        
        @Published var goalTasksInput: Double?
        @Published var goalTimelineInput: String
            
        @Published var showingNotificationsError = false
        @Published var showWholeNumberError = false
        @Published var showEnterNumberError = false
        @Published var showTitleError = false
        @Published var streakAlert = false
        
        @Published var notificationErrorMessage =
            """
            There was a problem setting your notification. Please check you have notifications enabled.
            """
        @Published var wholeNumberErrorMessage = "Enter a valid number of tasks required."
        @Published var enterNumberErrorMessage = "Enter a number of tasks required."
        @Published var titleErrorMessage = "Enter a valid goal title."
        @Published var streakAlertMessage =
            """
            Changing the streak timeline will reset any active streak to 1 of the newly selected timeline.
            """
        
        let frequencies = ["Daily", "Weekly", "Monthly"]
        let dayAbbreviations = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        @Published var reminderFrequency: String
        @Published var selectedDays: Set<Int>
        @Published var selectedDaysOfMonth: Set<Int>
        
        @Published var dismiss = false
        
        let dayOptions = (1...31).map { day in
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
        }
        
        func validateChanges(title: String?) {
            guard let validatedTitle = title else { return }
            
            guard validatedTitle.count > 0 else {
                showTitleError = true
                return
            }
            guard let validatedTasksInput = goalTasksInput else {
                showEnterNumberError = true
                return
            }
            
            guard validatedTasksInput.truncatingRemainder(dividingBy: 1) == 0 else {
                showWholeNumberError = true
                return
            }
                        
            guard validatedTasksInput > 0.0 && validatedTasksInput < Double(Int16.max) else {
                showWholeNumberError = true
                return
            }
            
            goal.updateStreakFromTimeline(goalTimelineInput)
            
            goal.goalTimeline = goalTimelineInput
            goal.goalTitle = validatedTitle
            goal.tasksNeeded = validatedTasksInput
            goal.goalReminderFrequency = reminderFrequency
            goal.weeklyReminderTimes = selectedDays
            goal.monthlyReminderTimes = selectedDaysOfMonth
                                                    
            dismiss = true
        }
    
        func updateReminder(_ goal: Goal) {
            Task { @MainActor in
                let success = await persistenceController.updateReminder(for: goal)

                if !success {
                    goal.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
        
        init(persistenceController: PersistenceController, goal: Goal) {
            self.persistenceController = persistenceController
            self.goal = goal
            self.goalTasksInput = goal.tasksNeeded
            self.goalTimelineInput = goal.goalTimeline
            self.originalTasksNeeded = goal.tasksNeeded
            self.reminderFrequency = goal.goalReminderFrequency == "" ? "Daily" : goal.goalReminderFrequency
            self.selectedDays = goal.goalWeeklyReminders
            self.selectedDaysOfMonth = goal.goalMonthlyReminders
        }
    }
}
