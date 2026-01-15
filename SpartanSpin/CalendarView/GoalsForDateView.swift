//
//  GoalForDateView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import SwiftUI

struct GoalsForDateView: View {
    @Environment(\.colorScheme) var colorScheme

    var date: DateComponents
    var recordsForDate: [GoalRecord]
    let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Colors.gradientC
                .ignoresSafeArea()
            VStack {
                if let day = date.day {
                    Text(String(day))
                }
                ForEach(recordsForDate) { record in
                    VStack {
                        let components = calendar.dateComponents([.day], from: record.date!)
                        if components.day == date.day {
                            Text(record.title!)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Spartan Spin")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
            }
        }
    }
}

#Preview {
    GoalsForDateView(date: DateComponents(calendar: .current, year: 2025, month: 11, day: 12), recordsForDate: [])
}
