//
//  GoalRecord-CoreDataHelpers.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/31/26.
//

import Foundation

extension GoalRecord {
    var recordTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var recordTimeline: String {
        get { timeline ?? "" }
        set { timeline = newValue }
    }
    
    var recordUnit: String {
        get { unit ?? "" }
        set { unit = newValue }
    }
}
