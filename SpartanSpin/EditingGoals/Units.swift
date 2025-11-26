//
//  Units.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import Foundation

struct Units {
    let repitition = "Repitition"
    let millileter = "mL"
    let ounce = "Ounce"
    let gallon = "Gallon"
    let mile = "Mile"
    let kilometer = "Kilometer"
    let second = "Second"
    let minute = "Hour"
    let hour = "Minute"
    let noUnit = "No Unit"
    var list: [String] {
        return [repitition, millileter, ounce, gallon, mile, kilometer, second, minute, hour, noUnit]
    }

    let repititions = "Repititions"
    let millileters = "mL"
    let ounces = "Ounces"
    let gallons = "Gallons"
    let miles = "Miles"
    let kilometers = "Kilometers"
    let seconds = "Seconds"
    let minutes = "Hours"
    let hours = "Minutes"
    var pluralList: [String] {
        return [repititions, millileters, ounces, gallons, miles, kilometers, seconds, minutes, hours, noUnit]
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
