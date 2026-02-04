//
//  CalendarExtensionTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class CalendarExtensionTests: BaseTestCase {
    func testDateGeneration() throws {
        let calendar = Calendar.current
        let january = returnJanuary()
        
        let monthInterval = try XCTUnwrap(
            calendar.dateInterval(of: .month, for: january),
            "Should create month interval for January"
        )
        
        let firstWeek = try XCTUnwrap(
            calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            "Should create week interval"
        )
        
        let interval = DateInterval(start: firstWeek.start, end: monthInterval.end)
        let components = DateComponents(hour: 0, minute: 0, second: 0)
        let dates = calendar.generateDates(inside: interval, matching: components)
        let datesInJanuary = dates.filter {
            return calendar.date($0, matchesComponents: DateComponents(month: 1))
        }
        
        XCTAssertEqual(31, datesInJanuary.count, "generateDates should create an array with 31 days for January")
    }
    
    func returnJanuary() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: Date.now)
        components.month = 1
        components.day = 1
        
        return calendar.date(from: components) ?? Date.now
    }
}
