//
//  GoalRecordUnwrapTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 2/3/26.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class GoalRecordUnwrapTests: BaseTestCase {

    func testRecordTitleUnwrap() {
        let record = GoalRecord(context: managedObjectContext)

        record.title = "Test record"
        XCTAssertEqual(record.recordTitle, "Test record", "Changing title should also change recordTitle.")

        record.recordTitle = "Updated record"
        XCTAssertEqual(record.title, "Updated record", "Changing recordTitle should also change title.")
    }
    
    func testRecordTimelineUnwrap() {
        let record = GoalRecord(context: managedObjectContext)

        record.timeline = "Monthly"
        XCTAssertEqual(record.recordTimeline, "Monthly", "Changing timeline should also change recordTimeline.")

        record.recordTimeline = "Weekly"
        XCTAssertEqual(record.timeline, "Weekly", "Changing recordTimeline should also change timeline.")
    }
    
    func testRecordUnitUnwrap() {
        let record = GoalRecord(context: managedObjectContext)

        record.unit = "Repitition"
        XCTAssertEqual(record.recordUnit, "Repitition", "Changing unit should also change recordUnit.")

        record.recordUnit = "Mile"
        XCTAssertEqual(record.unit, "Mile", "Changing recordUnit should also change unit.")
    }
}
