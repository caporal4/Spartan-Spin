//
//  HabitView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct HabitView: View {
    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var habit: Habit
    
    init(habit: Habit, persistenceController: PersistenceController) {
        self.habit = habit
        let viewModel = ViewModel(persistenceController: persistenceController, habit: habit)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.spartanSpinGreen
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    HabitCounterView(habit: habit, persistenceController: viewModel.persistenceController)
                    Spacer()
                    Text(viewModel.streakSentence(habit))
                        .font(.largeTitle)
                        .frame(height: 40)
                        .scaleEffect(habit.streak > 0 ? 1 : 0.3)
                        .opacity(habit.streak > 0 ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5), value: habit.streak)
                }
            }
        }
        .navigationTitle(habit.habitTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure?")
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    HabitView(habit: Habit.example(controller: persistenceController), persistenceController: .preview)
        .environmentObject(persistenceController)
}
