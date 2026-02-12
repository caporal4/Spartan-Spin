//
//  GoalCounterView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct GoalCounterView: View {
    @StateObject private var viewModel: ViewModel
    
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel
    
    @ObservedObject var goal: Goal
    
    init(goal: Goal, persistenceController: PersistenceController) {
        self.goal = goal
        let viewModel = ViewModel(persistenceController: persistenceController, goal: goal)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            Button("Undo Task", systemImage: "minus") {
                goal.undoTask()
                if let record = goal.findRecord(
                    for: Date.now,
                    records: mainViewModel.goalRecords,
                    timeline: goal.goalTimeline
                ) {
                    goal.updateRecord(record)
                }
            }
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
                .padding()
                .conditionalDecreaseFeedback(trigger: goal.tasksCompleted) { oldValue, newValue in
                    oldValue > newValue
                }
            VStack {
                Button("\(Int(goal.tasksCompleted))", action: viewModel.enterAmount)
                    .font(.system(size: Numbers.tasksCompletedFontSize))
                    .foregroundStyle(.white)
                    .alert("Enter Amount", isPresented: $viewModel.showPopup) {
                        TextField("Enter Amount", text: $viewModel.numberInput)
                            .keyboardType(.decimalPad)
                        Button("Cancel", role: .cancel) { }
                        Button("OK") {
                            viewModel.updateTasksFromTextField()
                            if let record = goal.findRecord(
                                for: Date.now,
                                records: mainViewModel.goalRecords,
                                timeline: goal.goalTimeline
                            ) {
                                goal.updateRecord(record)
                            }
                        }
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
                Text(viewModel.units.convertToPlural(goal))
                    .font(.title)
                    .foregroundStyle(.white)
            }
            Button("Complete Task", systemImage: "plus") {
                goal.doTask()
                if let record = goal.findRecord(
                    for: Date.now,
                    records: mainViewModel.goalRecords,
                    timeline: goal.goalTimeline
                ) {
                    goal.updateRecord(record)
                }
            }
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
                .padding()
                .conditionalIncreaseFeedback(trigger: goal.tasksCompleted) { oldValue, newValue in
                    newValue > oldValue
                }
            
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    
    GoalCounterView(goal: Goal.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(mainViewModel)
}
