//
//  ArrayExtension.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/25/25.
//

import Foundation

extension Array where Element == Goal {
    var dailyGoals: [Goal] {
        filter { $0.timeline == "Daily" }
    }
    
    var weeklyGoals: [Goal] {
        filter { $0.timeline == "Weekly" }
    }
    
    var monthlyGoals: [Goal] {
        filter { $0.timeline == "Monthly" }
    }
}
