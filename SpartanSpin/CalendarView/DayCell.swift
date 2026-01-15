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
    
    func checkMonth(date: DateComponents, displayedMonth: Date) -> Bool {
        if date.month != calendar.dateComponents([.month], from: displayedMonth).month {
            return false
        }
        return true
    }

    var body: some View {
        if checkMonth(date: date, displayedMonth: displayedMonth) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(.blue)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(.blue, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
                
                Text("\(date.day!)")
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(height: 40)
        } else {
            Color.clear
                .frame(width: 36, height: 36)
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let date = Date()
    DayCell(date: calendar.dateComponents([.day, .month, .year], from: date), displayedMonth: date, isSelected: true, isToday: true)
}
