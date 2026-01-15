//
//  MonthProgressView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct MonthProgressView: View {
    let goals: [Goal]

    var body: some View {
        if !goals.isEmpty {
            Section("Monthly Goals") {
                ForEach(goals) { goal in
                    NavigationLink(value: goal) {
                        ZStack(alignment: .leading) {
                            ContentViewRectangle()
                            ContentViewRow(goal: goal)
                        }
                    }
                    .listRowBackground(Colors.spartanSpinGreen)
                    .accessibilityIdentifier(goal.goalTitle)
                }
            }
        }
    }
}

#Preview {
    MonthProgressView(goals: [])
}
