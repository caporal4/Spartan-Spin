//
//  WeekProgressView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct WeekProgressView: View {
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel
    
    var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2  // Monday
        return cal
    }
    let month: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(weeksInMonth, id: \.self) { weekStart in
                NavigationLink(value: weekStart) {
                    WeekProgressViewRow(
                        weekStart: weekStart,
                        weekEnd: weekEnd(of: weekStart),
                        progress: calculateProgress(records: weeklyRecords(
                            date: weekStart,
                            records: mainViewModel.goalRecords
                        ))
                    )
                }
            }
        }
        .padding()
    }
    
    private var weeksInMonth: [Date] {
        var calendar: Calendar {
            var cal = Calendar.current
            cal.firstWeekday = 2  // Monday
            return cal
        }
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
    
    func calculateProgress(records: [GoalRecord]) -> Double {
        guard records.count > 0 else { return 0.0 }
        var temporaryValue = 0.0
        
        var numerator = 0.0
        var denominator = 0.0
                
        for record in records {
             if record.tasksCompleted > record.tasksNeeded {
                temporaryValue = record.tasksNeeded
                numerator += temporaryValue
                denominator += record.tasksNeeded
            } else {
                numerator += record.tasksCompleted
                denominator += record.tasksNeeded
            }
        }
        let answer = numerator / denominator
        return answer
    }
    
    func weeklyRecords(date: Date, records: [GoalRecord]) -> [GoalRecord] {
        let weeklyRecords = records.filter { record in
            guard let recordDate = record.date else { return false }
            guard record.recordTimeline == "Weekly" else { return false }
            return Calendar.current.isDate(recordDate, equalTo: date, toGranularity: .weekOfYear)
        }
        
        return weeklyRecords
    }
    
    // Add error handling
    func weekEnd(of date: Date) -> Date {
        guard let weekEnd =  Calendar.current.date(byAdding: .day, value: 6, to: date) else { return date }
        return weekEnd
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    
    WeekProgressView(month: Date())
        .environmentObject(mainViewModel)
}
