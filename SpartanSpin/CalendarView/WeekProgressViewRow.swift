//
//  WeekProgressViewRow.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct WeekProgressViewRow: View {
    let weekStart: Date

    var body: some View {
        HStack {
            Text(weekLabel)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            ProgressView(value: weeklyProgress)
                .tint(.blue)
        }
    }
    private var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: weekStart))"
    }
    
//    private var completedGoals: Int {
//        goals.filter { $0.wasCompletedForWeek(weekStart) }.count
//    }
    
    private var weeklyProgress: Double {
        return Double(1) / Double(2)
    }
}

#Preview {
    WeekProgressViewRow(weekStart: Date.now)
}
