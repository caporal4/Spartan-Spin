//
//  Units.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

struct Units {
    let repetition = "Repetition"
    let ounce = "Ounce"
    let gallon = "Gallon"
    let mile = "Mile"
    let second = "Second"
    let minute = "Hour"
    let hour = "Minute"
    let classUnit = "Class"
    let noUnit = "No Unit"
    var list: [String] {
        return [repetition, ounce, gallon, mile, second, minute, hour, classUnit, noUnit]
    }

    let repetitions = "Repetitions"
    let ounces = "Ounces"
    let gallons = "Gallons"
    let miles = "Miles"
    let seconds = "Seconds"
    let minutes = "Hours"
    let hours = "Minutes"
    let classes = "Classes"
    var pluralList: [String] {
        return [repetitions, ounces, gallons, miles, seconds, minutes, hours, classes, noUnit]
    }
}

extension Units {
    func convertToPlural(_ goal: Goal) -> String {
        guard goal.unit != "No Unit" else { return "" }
        
        if goal.tasksNeeded == 1 {
            return goal.goalUnit
        } else {
            if let index = list.firstIndex(of: goal.goalUnit) {
                if goal.tasksNeeded == 1 {
                    return list[index]
                } else {
                    return pluralList[index]
                }
            }
            return goal.goalUnit
        }
    }
}
