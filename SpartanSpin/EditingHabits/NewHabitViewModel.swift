//
//  NewHabitViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import Foundation
import SwiftUI

extension NewHabitView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        
        let units = Units()
        let timelines = Timelines()
        
        @Published var title = ""
        @Published var tasksNeeded: Double?
        @Published var unit = "No Unit"
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
        @Published var titleErrorMessage = "Enter a valid habit title."
        
        @Published var dismiss = false
        
        func checkSettings() {
            Task { @MainActor in
                if reminderEnabled {
                    let success = await persistenceController.addReminderNewHabit()
    
                    if success == false {
                        reminderEnabled = false
                        showingNotificationsError = true
                    }
                }
            }
        }
        
        func createAppSettingsURL() -> URL? {
            let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString)
            return settingsURL
        }
        
        func addHabit() {
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
            let newHabit = Habit(context: viewContext)
            newHabit.id = UUID()
            newHabit.title = title
            newHabit.timeline = timeline
            newHabit.tasksCompleted = 0
            newHabit.streak = 0
            newHabit.lastStreakReset = Date.now
            newHabit.lastTaskReset = Date.now
            newHabit.reminderEnabled = reminderEnabled
            newHabit.reminderTime = reminderTime
            newHabit.tasksNeeded = tasksNeeded
            newHabit.unit = unit
            
            updateReminder(newHabit)
            
            try? viewContext.save()
            dismiss = true
        }
        
        private func updateReminder(_ habit: Habit) {
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
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
        }
    }
}
