//
//  GoalCounterView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct GoalCounterView: View {
    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var goal: Goal
    
    init(goal: Goal, persistenceController: PersistenceController) {
        self.goal = goal
        let viewModel = ViewModel(persistenceController: persistenceController, goal: goal)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            Button("Undo Task", systemImage: "minus", action: viewModel.undoTask)
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
                .padding()
                .sensoryFeedback(trigger: goal.tasksCompleted) { oldValue, newValue in
                    if oldValue > newValue {
                        .decrease
                    } else {
                        nil
                    }
                }
            VStack {
                Button("\(Int(goal.tasksCompleted))", action: viewModel.enterAmount)
                    .font(.system(size: Numbers.tasksCompletedFontSize))
                    .foregroundStyle(.white)
                    .alert("Enter Amount", isPresented: $viewModel.showPopup) {
                        TextField("Enter Amount", text: $viewModel.numberInput)
                            .keyboardType(.decimalPad)
                        Button("Cancel", role: .cancel) { }
                        Button("OK", action: viewModel.updateTasks)
                    }
                    .alert(
                        viewModel.errorMessage,
                        isPresented: $viewModel.showError
                    ) {
                        Button("OK", action: viewModel.invalidNumber)
                    }
                Text("/\(Int(goal.tasksNeeded))")
                    .font(.title)
                    .foregroundStyle(.white)
                Text(LocalizedStringKey(viewModel.convertToPlural(goal)))
                    .font(.title)
                    .foregroundStyle(.white)
            }
            Button("Complete Task", systemImage: "plus", action: viewModel.doTask)
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
                .padding()
                .sensoryFeedback(trigger: goal.tasksCompleted) { oldValue, newValue in
                    if newValue > oldValue {
                        .increase
                    } else {
                        nil
                    }
                }
            
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    GoalCounterView(goal: Goal.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(persistenceController)
}
