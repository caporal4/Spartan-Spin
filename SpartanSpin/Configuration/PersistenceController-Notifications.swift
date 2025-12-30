//
//  PersistenceController-Notifications.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation
import UserNotifications

extension PersistenceController {
    @MainActor
    func updateReminder(for goal: Goal) async -> Bool {
        removeReminders(for: goal)

        if goal.reminderEnabled {
            let success = await addReminder(for: goal)
            return success
        } else {
            return true
        }
    }
    
    func addReminder(for goal: Goal) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: goal)
                } else {
                    return false
                }
            case .authorized:
                try await placeReminders(for: goal)

            default:
                return false
            }

            return true
        } catch {
            return false
        }
    }
    
    func ensureNotificationPermissions() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    return true
                } else {
                    return false
                }
            case .authorized:
                return true

            default:
                return false
            }
        } catch {
            return false
        }
    }

    func removeReminders(for goal: Goal) {
        let center = UNUserNotificationCenter.current()
        let baseId = goal.objectID.uriRepresentation().absoluteString
        
        var identifiers = [baseId] // For daily
        
        // Add all possible weekly IDs
        for weekday in 1...7 {
            identifiers.append("\(baseId)-weekday\(weekday)")
        }
        
        // Add all possible monthly IDs
        for day in 1...31 {
            identifiers.append("\(baseId)-day\(day)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeMultipleReminders(_ goals: [Goal]) {
        for goal in goals {
            removeReminders(for: goal)
        }
    }

    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }

    private func placeReminders(for goal: Goal) async throws {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = goal.goalTitle
        let baseId = goal.objectID.uriRepresentation().absoluteString
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: goal.goalReminderTime)

        switch goal.reminderFrequency {
        case "Daily":
            let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
            let request = UNNotificationRequest(identifier: baseId, content: content, trigger: trigger)
            return try await UNUserNotificationCenter.current().add(request)
        case "Weekly":
            for weekday in goal.goalWeeklyReminders {
                var components = timeComponents
                let calendarWeekday = weekday == 7 ? 1 : weekday + 1
                components.weekday = calendarWeekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let id = "\(baseId)-weekday\(weekday)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
            }
        case "Monthly":
            for day in goal.goalMonthlyReminders {
                var components = timeComponents
                components.day = day // 1-31
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let id = "\(baseId)-day\(day)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
            }
        default: return
        }
    }
}
