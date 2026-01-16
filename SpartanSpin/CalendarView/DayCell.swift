//
//  DayCell.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/13/26.
//

import SwiftUI

struct DayCell: View {
    let date: DateComponents
    let displayedMonth: Date
    let isSelected: Bool
    let isToday: Bool

    private let calendar = Calendar.current
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if checkMonth(date: date, displayedMonth: displayedMonth) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(.white)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
                
                Text("\(unwrapDay(day: date.day))")
                    .foregroundStyle(.white)
            }
            .frame(height: 40)
        } else {
            Color.clear
                .frame(width: 36, height: 36)
        }
    }
    
    func unwrapDay(day: Int?) -> Int {
        guard let unwrappedDay = day else { return 0 }
        return unwrappedDay
    }
    
    func checkMonth(date: DateComponents, displayedMonth: Date) -> Bool {
        if date.month != calendar.dateComponents([.month], from: displayedMonth).month {
            return false
        }
        return true
    }
}

#Preview {
    let calendar = Calendar.current
    let date = Date()
    DayCell(
        date: calendar.dateComponents([.day, .month, .year], from: date),
        displayedMonth: date,
        isSelected: true,
        isToday: true
    )
}
