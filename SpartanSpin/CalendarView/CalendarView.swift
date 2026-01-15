//
//  CalendarView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/13/26.
//

import SwiftUI

struct MonthCalendarView: View {
    @State private var displayedMonth: Date = Date()
    @Binding var selectedDate: DateComponents?
    
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let cellHeight: CGFloat = 40
    let cellSpacing: CGFloat = 12
    let maxRows: CGFloat = 6
    var gridHeight: CGFloat {
        cellHeight * cellSpacing * maxRows
    }
    
    var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }
    
    func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else { return [] }
        
        let dates = calendar.generateDates(
            inside: DateInterval(start: firstWeek.start, end: monthInterval.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
        
        print(dates.count)

        return dates
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthTitle)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            
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
                        isToday: calendar.isDateInToday(date)
                    )
                    .onTapGesture {
                        selectedDate = convertToDateComponents(date: date)
                    }
                }
            }
        }
        .frame(height: 360, alignment: .topLeading)
        .padding()
    }
    
    func convertToDate(date: DateComponents) -> Date {
        return calendar.date(from: date)!
    }
    func convertToDateComponents(date: Date) -> DateComponents {
        return calendar.dateComponents([.day, .month, .year], from: date)
    }
}

#Preview {
    MonthCalendarView(selectedDate: .constant(nil))
}
