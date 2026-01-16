//
//  WeekProgressViewRow.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct WeekProgressViewRow: View {
    let weekStart: Date
    let weekEnd: Date

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Text(weekLabel(dateOne: weekStart, dateTwo: weekEnd))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 135, alignment: .leading)
            ProgressView(value: weeklyProgress)
                .tint(.white)
        }
    }
    
    func weekLabel(dateOne: Date, dateTwo: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: dateOne)) - \(formatter.string(from: dateTwo))"
    }
    
    // Add total progress of weekly goals
    private var weeklyProgress: Double {
        return Double(1) / Double(2)
    }
}

#Preview {
    WeekProgressViewRow(weekStart: Date.now, weekEnd: Date.now)
}
