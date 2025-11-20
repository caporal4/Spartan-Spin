//
//  HabitView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct HabitView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var habit: Habit
    
    init(habit: Habit, persistenceController: PersistenceController) {
        self.habit = habit
        let viewModel = ViewModel(persistenceController: persistenceController, habit: habit)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Colors.gradientC
                .ignoresSafeArea()
            VStack {
                Spacer()
                HabitCounterView(habit: habit, persistenceController: viewModel.persistenceController)
                Spacer()
                Spacer()
                Text(viewModel.streakSentence(habit))
                    .padding()
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(height: 40)
                    .scaleEffect(habit.streak > 0 ? 1 : 0.3)
                    .opacity(habit.streak > 0 ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: habit.streak)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(habit.habitTitle)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
            }
            ToolbarItemGroup {
                Button("Edit Habit", systemImage: "ellipsis") {
                    viewModel.showEditHabitView = true
                }
                Button("Delete Habit", systemImage: "trash") {
                    viewModel.showingDeleteAlert = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showEditHabitView) {
            EditHabitView(habit: habit, persistenceController: viewModel.persistenceController)
        }
        .alert("Delete habit: \(habit.habitTitle)", isPresented: $viewModel.showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.delete(habit)
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
    
    HabitView(habit: Habit.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(persistenceController)
}
