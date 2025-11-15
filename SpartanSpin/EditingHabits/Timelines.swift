//
//  Timelines.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/14/25.
//

import Foundation

struct Timelines {
    let daily = "Daily"
    let weekly = "Weekly"
    let monthly = "Monthly"
    let yearly = "Yearly"
    var list: [String] {
        return [daily, weekly, monthly, yearly]
    }
}
