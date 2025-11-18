//
//  HabitCounterView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct HabitCounterView: View {
    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var habit: Habit
    
    init(habit: Habit, persistenceController: PersistenceController) {
        self.habit = habit
        let viewModel = ViewModel(persistenceController: persistenceController, habit: habit)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            Button("Undo Task", systemImage: "minus", action: viewModel.undoTask)
                .labelStyle(.iconOnly)
                .padding()
                .sensoryFeedback(trigger: habit.tasksCompleted) { oldValue, newValue in
                    if oldValue > newValue {
                        .decrease
                    } else {
                        nil
                    }
                }
            VStack {
                Button("\(habit.tasksCompleted)", action: viewModel.enterAmount)
                    .font(.system(size: Numbers.tasksCompletedFontSize))
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
                Text("/\(habit.tasksNeeded)")
                    .font(.title)
                Text(LocalizedStringKey(viewModel.convertToPlural(habit)))
                    .font(.title)
            }
            Button("Complete Task", systemImage: "plus", action: viewModel.doTask)
                .labelStyle(.iconOnly)
                .padding()
                .sensoryFeedback(trigger: habit.tasksCompleted) { oldValue, newValue in
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
    
    HabitCounterView(habit: Habit.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(persistenceController)
}
