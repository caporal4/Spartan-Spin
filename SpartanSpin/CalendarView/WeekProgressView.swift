//
//  WeekProgressView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct WeekProgressView: View {
    let month: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(weeksInMonth, id: \.self) { weekStart in
                NavigationLink(value: weekStart) {
                    WeekProgressViewRow(
                        weekStart: weekStart,
                        weekEnd: weekEnd(of: weekStart)
                    )
                }
            }
        }
        .padding()
    }
    
    private var weeksInMonth: [Date] {
        let calendar = Calendar.current
        var weeks: [Date] = []
        
        guard let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: month)
        ) else { return [] }
        guard let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        var currentWeek = calendar.dateInterval(of: .weekOfMonth, for: monthStart)?.start ?? monthStart
        
        while currentWeek <= monthEnd {
            weeks.append(currentWeek)
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) else { break }
            currentWeek = nextWeek
        }
        
        return weeks
    }
    
    // Add error handling
    func weekEnd(of date: Date) -> Date {
        guard let weekEnd =  Calendar.current.date(byAdding: .day, value: 6, to: date) else { return date }
        return weekEnd
    }
}

#Preview {
    WeekProgressView(month: Date())
}
