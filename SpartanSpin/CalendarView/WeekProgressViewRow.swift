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
    let progress: Double

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Text(weekLabel(dateOne: weekStart, dateTwo: weekEnd))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(minWidth: 135, alignment: .leading)
            ProgressView(value: progress)
                .tint(.white)
        }
    }
    func weekLabel(dateOne: Date, dateTwo: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: dateOne)) - \(formatter.string(from: dateTwo))"
    }
}

#Preview {
    WeekProgressViewRow(weekStart: Date.now, weekEnd: Date.now, progress: 0.5)
}
