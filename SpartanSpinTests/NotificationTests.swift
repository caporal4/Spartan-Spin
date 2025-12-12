//
//  NotificationTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 11/26/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class NotificationTests: BaseTestCase {
    override func setUp() {
        super.setUp()
        // Clear all pending notifications before each test
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    override func tearDown() {
        // Also clear after each test to be safe
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        super.tearDown()
    }
    
    let persistenceContainer = PersistenceController()

    func testDailyNotifications() {
        let content = UNMutableNotificationContent()

        let goal = Goal(context: managedObjectContext)
        
        goal.title = "Run"
        goal.reminderEnabled = true
        goal.goalReminderTime = Date.now
        
        content.sound = .default
        content.title = goal.goalTitle
        
        let timeComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: goal.goalReminderTime)
        let baseId = goal.objectID.uriRepresentation().absoluteString
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        let request = UNNotificationRequest(identifier: baseId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                XCTFail("Error adding notification request: \(error)")
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 1)
        }
        
        persistenceContainer.removeReminders(for: goal)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 0)
        }
    }
    
    func testWeeklyNotifications() {
        let content = UNMutableNotificationContent()
        
        let goal = Goal(context: managedObjectContext)
        
        goal.title = "Run"
        goal.reminderEnabled = true
        goal.goalReminderTime = Date.now
        goal.weeklyReminderTimes = Set(1...7)
        
        content.sound = .default
        content.title = goal.goalTitle
        
        let timeComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: goal.goalReminderTime)
        let baseId = goal.objectID.uriRepresentation().absoluteString
        
        for weekday in goal.goalWeeklyReminders {
            var components = timeComponents
            let calendarWeekday = weekday == 7 ? 1 : weekday + 1
            components.weekday = calendarWeekday
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id = "\(baseId)-weekday\(weekday)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    XCTFail("Error adding notification request: \(error)")
                }
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 7)
        }
        
        persistenceContainer.removeReminders(for: goal)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 0)
        }
    }
    
    func testMonthlyNotifications() {
        let content = UNMutableNotificationContent()

        let goal = Goal(context: managedObjectContext)
        
        goal.title = "Run"
        goal.reminderEnabled = true
        goal.goalReminderTime = Date.now
        goal.monthlyReminderTimes = Set(1...31)
        
        content.sound = .default
        content.title = goal.goalTitle
        
        let timeComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: goal.goalReminderTime)
        let baseId = goal.objectID.uriRepresentation().absoluteString
        
        for day in goal.goalMonthlyReminders {
            var components = timeComponents
            components.day = day // 1-31
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id = "\(baseId)-day\(day)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    XCTFail("Error adding notification request: \(error)")
                }
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 31)
        }
        
        persistenceContainer.removeReminders(for: goal)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 0)
        }
    }
    
    func testRemoveMultipleReminders() {
        var goals: [Goal] = []

        for loop in 1...2 {
            let content = UNMutableNotificationContent()
            
            let goal = Goal(context: managedObjectContext)
            goal.title = "Run"
            goal.reminderEnabled = true
            goal.goalReminderTime = Date.now
            goal.monthlyReminderTimes = Set(1...31)
            
            goals.append(goal)
            
            content.sound = .default
            content.title = goal.goalTitle
            
            let timeComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: goal.goalReminderTime)
            let baseId = goal.objectID.uriRepresentation().absoluteString
            
            for day in goal.goalMonthlyReminders {
                var components = timeComponents
                components.day = day // 1-31
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let id = "\(baseId)-day\(day)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    if let error = error {
                        XCTFail("Error adding notification request for goal \(loop): \(error)")
                    }
                }
            }
        }
                
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 62)
        }
        
        persistenceContainer.removeMultipleReminders(goals)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 0)
        }
    }
}
