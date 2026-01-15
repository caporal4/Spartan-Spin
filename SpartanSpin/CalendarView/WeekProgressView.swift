//
//  WeekProgressView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct WeekProgressView: View {
    @State private var month: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Goals Progress")
                .font(.headline)
            
            ForEach(weeksInMonth, id: \.self) { weekStart in
                NavigationLink(value: weekStart) {
                    WeekProgressViewRow(
                        weekStart: weekStart
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
}

#Preview {
    WeekProgressView()
}
