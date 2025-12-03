//
//  NewGoalViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import Foundation
import SwiftUI

extension NewGoalView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        
        let units = Units()
        let timelines = Timelines()
        var calendar = Calendar.current

        @Published var title: String
        @Published var tasksNeeded: Double?
        @Published var unit: String
        @Published var timeline = "Daily"
        @Published var reminderEnabled = false
        @Published var reminderTime = Date.now
        
        @Published var showingNotificationsError = false
        @Published var showWholeNumberError = false
        @Published var showEnterNumberError = false
        @Published var showTitleError = false
        
        @Published var notificationErrorMessage =
            """
            There was a problem setting your notification. Please check you have notifications enabled.
            """
        @Published var wholeNumberErrorMessage = "Enter a valid number of tasks required."
        @Published var enterNumberErrorMessage = "Enter a number of tasks required."
        @Published var titleErrorMessage = "Enter a valid goal title."
        
        let dayAbbreviations = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        @Published var reminderFrequency = "Daily"
        @Published var selectedDays = Set<Int>()
        @Published var selectedDaysOfMonth = Set<Int>()
        
        @Published var dismiss = false
    
        let dayOptions = (1...31).map { day in
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
        }
        
        func addGoal() {
            guard title.count > 0 else {
                showTitleError = true
                return
            }
            guard let tasksNeeded else {
                showEnterNumberError = true
                return
            }
            
            guard tasksNeeded.truncatingRemainder(dividingBy: 1) == 0 else {
                showWholeNumberError = true
                return
            }
            
            let convertedNumber = Int16(tasksNeeded)
            guard convertedNumber > 0 && convertedNumber < Int(Int16.max) else {
                showWholeNumberError = true
                return
            }
                        
            let viewContext = persistenceController.container.viewContext
            let newGoal = Goal(context: viewContext)
            newGoal.id = UUID()
            newGoal.title = title
            newGoal.timeline = timeline
            newGoal.tasksCompleted = 0
            newGoal.streak = 0
            newGoal.lastStreakReset = Date.now
            newGoal.lastTaskReset = Date.now
            newGoal.reminderEnabled = reminderEnabled
            newGoal.reminderFrequency = reminderFrequency
            newGoal.reminderTime = reminderTime
            newGoal.weeklyReminderTimes = selectedDays
            newGoal.monthlyReminderTimes = selectedDaysOfMonth
            newGoal.tasksNeeded = tasksNeeded
            newGoal.unit = unit
            
            callPersistenceToUpdateReminder(newGoal)
            
            try? viewContext.save()
            dismiss = true
        }
        
        func checkSettings() {
            Task { @MainActor in
                if reminderEnabled {
                    let success = await persistenceController.ensureNotificationPermissions()
    
                    if success == false {
                        reminderEnabled = false
                        showingNotificationsError = true
                    }
                }
            }
        }
        
        private func callPersistenceToUpdateReminder(_ goal: Goal) {
            Task { @MainActor in
                let success = await persistenceController.updateReminder(for: goal)

                if !success {
                    goal.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
        
        init(title: String, unit: String, persistenceController: PersistenceController) {
            self.title = title
            self.unit = unit
            self.persistenceController = persistenceController
        }
    }
}
