//
//  MonthlyMoveListView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/11/25.
//

import SwiftUI

struct MonthlyMoveListView: View {
    @Environment(\.colorScheme) var colorScheme

    let persistenceController: PersistenceController
    let move: String
    let goals: [Goal]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    if !goals.dailyGoals.isEmpty {
                        Section("Daily Goals") {
                            ForEach(goals.dailyGoals) { goal in
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
                    if !goals.weeklyGoals.isEmpty {
                        Section("Weekly Goals") {
                            ForEach(goals.weeklyGoals) { goal in
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
                    if !goals.monthlyGoals.isEmpty {
                        Section("Monthly Goals") {
                            ForEach(goals.monthlyGoals) { goal in
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
                .scrollContentBackground(.hidden)
                .background(Colors.gradientC.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Spartan Spin")
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                    }
                }
                .navigationDestination(for: Goal.self) { goal in
                    GoalView(goal: goal, persistenceController: persistenceController)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .accessibilityIdentifier("Monthly Move List Sheet")
    }
}

#Preview {
    MonthlyMoveListView(persistenceController: .preview, move: "Push-ups", goals: [])
}
