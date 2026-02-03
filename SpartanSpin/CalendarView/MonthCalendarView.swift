//
//  MonthCalendarView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/13/26.
//

import SwiftUI

struct MonthCalendarView: View {
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel
    let displayedMonth: Date
    @Binding var selectedDate: DateComponents?
    
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let cellHeight: CGFloat = 40
    let cellSpacing: CGFloat = 12
    let maxRows: CGFloat = 6
    var gridHeight: CGFloat {
        cellHeight * cellSpacing * maxRows
    }
    
    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) {
                    Text($0)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(daysInMonth(), id: \.self) { date in
                    DayCell(
                        date: calendar.dateComponents([.day, .month, .year], from: date),
                        displayedMonth: displayedMonth,
                        isSelected:
                            calendar.dateComponents([.day], from: date).day == selectedDate?.day &&
                        calendar.dateComponents([.month], from: date).month == selectedDate?.month &&
                        calendar.dateComponents([.year], from: date).year == selectedDate?.year,
                        isToday: calendar.isDateInToday(date),
                        progress: calculateProgress(
                            records: dailyRecords(date: date, records: mainViewModel.goalRecords)
                        )
                    )
                    .onTapGesture {
                        selectedDate = convertToDateComponents(date: date)
                    }
                }
            }
        }
        .frame(alignment: .topLeading)
        .padding()
        .onAppear {
            mainViewModel.displayedMonth = Date.now
            mainViewModel.createHistoricRecords()
            mainViewModel.createNewRecords()
        }
    }
    
    // Add error handling
    func convertToDate(date: DateComponents) -> Date {
        guard let convertedDate = calendar.date(from: date) else { return Date.now }
        return convertedDate
            
    }
    
    func convertToDateComponents(date: Date) -> DateComponents {
        return calendar.dateComponents([.day, .month, .year], from: date)
    }
    
    func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else { return [] }
        
        let dates = calendar.generateDates(
            inside: DateInterval(start: firstWeek.start, end: monthInterval.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
        
        return dates
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
    
    func dailyRecords(date: Date, records: [GoalRecord]) -> [GoalRecord] {
        let dailyRecords = records.filter { record in
            guard let recordDate = record.date else { return false }
            guard record.recordTimeline == "Daily" else { return false }
            return Calendar.current.isDate(recordDate, equalTo: date, toGranularity: .dayOfYear)
        }
        
        return dailyRecords
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    let components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    MonthCalendarView(displayedMonth: Date(), selectedDate: .constant(components))
        .environmentObject(mainViewModel)
}
