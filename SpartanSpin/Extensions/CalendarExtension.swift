//
//  CalendarExtension.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/13/26.
//

import Foundation

extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date, date < interval.end {
                dates.append(date)
            } else {
                stop = true
            }
        }

        return dates
    }
}
