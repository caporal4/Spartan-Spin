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
    let progress: Double

    private let calendar = Calendar.current
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if checkMonth(date: date, displayedMonth: displayedMonth) {
            ZStack {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                if isToday {
                    Circle()
                        .fill(.white)
                        .frame(width: 30, height: 30)
                    Text("\(date.day ?? 0)")
                        .foregroundStyle(.black)
                } else {
                    Text("\(date.day ?? 0)")
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 40)
        } else {
            Color.clear
                .frame(width: 36, height: 36)
        }
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
        isToday: true,
        progress: 0.25
    )
}
