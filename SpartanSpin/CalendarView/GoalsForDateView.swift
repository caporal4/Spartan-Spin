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

    var body: some View {
        ZStack {
            Colors.gradientC
                .ignoresSafeArea()
            if let day = date.day {
                Text(String(day))
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
    GoalsForDateView(date: DateComponents(calendar: .current, year: 2025, month: 11, day: 12))
}
