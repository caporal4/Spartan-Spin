//
//  EditHabitViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation
import SwiftUI

extension EditHabitView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        var habit: Habit
        
        let units = Units()
        let timelines = Timelines()
        
        let originalTasksNeeded: Double
        
        @Published var habitTasksInput: Double?
        @Published var habitTimelineInput: String
            
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
        @Published var titleErrorMessage = "Enter a valid habit title."
        @Published var streakAlertMessage =
            """
            Changing the streak timeline will reset any active streak to 1 of the newly selected unit.
            """
        
        @Published var dismiss = false
        
        func validateChanges(title: String?) {
            guard let validatedTitle = title else { return }
            
            guard validatedTitle.count > 0 else {
                showTitleError = true
                return
            }
            guard let validatedTasksInput = habitTasksInput else {
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
            
            updateStreakFromTimeline()
            
            habit.habitTimeline = habitTimelineInput
            habit.habitTitle = validatedTitle
            habit.tasksNeeded = validatedTasksInput
            
            updateStreakFromTasksAdded()
                                
            dismiss = true
        }
        
        func createAppSettingsURL() -> URL? {
            let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString)
            return settingsURL
        }
    
        func updateReminder() {
            persistenceController.removeReminders(for: habit)
    
            Task { @MainActor in
                if habit.reminderEnabled {
                    let success = await persistenceController.addReminder(for: habit)
    
                    if success == false {
                        habit.reminderEnabled = false
                        showingNotificationsError = true
                    }
                }
            }
        }
        
        private func updateStreakFromTimeline() {
            if habit.habitTimeline != habitTimelineInput {
                habit.streak = 1
                habit.lastStreakReset = Date.now
                habit.lastStreakIncrease = nil
            }
        }
        
        private func updateStreakFromTasksAdded() {
            if habit.tasksCompleted < habit.tasksNeeded {
                habit.streak -= 1
                habit.lastStreakIncrease = nil
            }
        }
        
        init(persistenceController: PersistenceController, habit: Habit) {
            self.persistenceController = persistenceController
            self.habit = habit
            self.habitTasksInput = habit.tasksNeeded
            self.habitTimelineInput = habit.habitTimeline
            self.originalTasksNeeded = habit.tasksNeeded
        }
    }
}
