//
//  GoalSectionView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/11/25.
//

import SwiftUI

struct GoalSectionView: View {
    let title: String
    let goals: [Goal]
    let onDelete: (IndexSet) -> Void
    let reloadData: () -> Void
    
    var body: some View {
        if !goals.isEmpty {
            Section(title) {
                ForEach(goals) { goal in
                    NavigationLink(value: goal) {
                        ZStack(alignment: .leading) {
                            ContentViewRectangle()
                            ContentViewRow(goal: goal)
                        }
                    }
                    .listRowBackground(Colors.spartanSpinGreen)
                    .onReceive(goal.objectWillChange) { _ in
                        reloadData()
                    }
                    .accessibilityIdentifier(goal.goalTitle)
                }
                .onDelete(perform: onDelete)
            }
        }
    }
}

#Preview {
    GoalSectionView(title: "Daily", goals: [], onDelete: {_ in }, reloadData: {})
}
