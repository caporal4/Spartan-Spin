//
//  GoalView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct GoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var goal: Goal
    
    init(goal: Goal, persistenceController: PersistenceController) {
        self.goal = goal
        let viewModel = ViewModel(persistenceController: persistenceController, goal: goal)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Colors.gradientC
                .ignoresSafeArea()
            VStack {
                Spacer()
                GoalCounterView(goal: goal, persistenceController: viewModel.persistenceController)
                Spacer()
                Spacer()
                Text(goal.streakSentence())
                    .padding()
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(height: Numbers.streakFrame)
                    .scaleEffect(goal.streak > 0 ? Numbers.streakScaleOne : Numbers.streakScaleTwo)
                    .opacity(goal.streak > 0 ? Numbers.streakOpacityOne : Numbers.streakOpacityTwo)
                    .animation(.spring(
                        response: Numbers.streakResponse,
                        dampingFraction: Numbers.streakDamping),
                               value: goal.streak
                    )
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(goal.goalTitle)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                    .accessibilityIdentifier("Goal Title Toolbar")
            }
            ToolbarItemGroup {
                Button("Edit Goal", systemImage: "ellipsis") {
                    viewModel.showEditGoalView = true
                }
                .tint(colorScheme == .dark ? .white : .black)
                Button("Delete Goal", systemImage: "trash") {
                    viewModel.showingDeleteAlert = true
                }
                .tint(colorScheme == .dark ? .white : .black)
            }
        }
        .sheet(isPresented: $viewModel.showEditGoalView) {
            EditGoalView(goal: goal, persistenceController: viewModel.persistenceController)
        }
        .alert("Delete goal: \(goal.goalTitle)", isPresented: $viewModel.showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.delete(goal)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    GoalView(goal: Goal.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(persistenceController)
}
