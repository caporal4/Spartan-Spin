//
//  ContentView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel: ViewModel
    
    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habits.isEmpty {
                    ZStack {
                        Colors.gradientC
                            .ignoresSafeArea()
                        VStack {
                            Text("Create a new habit!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.spartanSpinGreen)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: viewModel.showNewHabitView) {
                                Label("Add Habit", systemImage: "plus.app")
                                    .font(.headline)
                                    .padding()
                                    .background(Colors.spartanSpinGreen.opacity(0.2))
                                    .cornerRadius(10)
                            }
#if DEBUG
                            Button(action: viewModel.persistenceController.createSampleData) {
                                Label("Add Sample Habits", systemImage: "plus.app")
                                    .font(.headline)
                                    .padding()
                                    .background(Colors.spartanSpinGreen.opacity(0.2))
                                    .cornerRadius(10)
                            }
#endif
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Spartan Spin")
                                .font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                        }
                    }
                    .sheet(isPresented: $viewModel.newHabit) {
                        NewHabitView(persistenceController: viewModel.persistenceController)
                    }
                } else {
                    List {
                        Section {
                            ForEach(viewModel.habits) { habit in
                                NavigationLink(value: habit) {
                                    ZStack(alignment: .leading) {
                                        ContentViewRectangle()
                                        ContentViewRow(habit: habit)
                                    }
                                }
                                .listRowBackground(Colors.spartanSpinGreen)
                                .onReceive(habit.objectWillChange) { _ in
                                    viewModel.reloadData()
                                }
                                .accessibilityIdentifier(habit.habitTitle)
                            }
                            .onDelete(perform: viewModel.delete)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Colors.gradientC)
                    .navigationDestination(for: Habit.self) { habit in
                        HabitView(habit: habit, persistenceController: viewModel.persistenceController)
                    }
                    .sheet(isPresented: $viewModel.newHabit) {
                        NewHabitView(persistenceController: viewModel.persistenceController)
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Spartan Spin")
                                .font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                        }
                        
                        ToolbarItem {
                            Button(action: viewModel.showNewHabitView) {
                                Label("Add Habit", systemImage: "plus.app")
                            }
                        }
#if DEBUG
                        ToolbarItem {
                            Button {
                                viewModel.persistenceController.createSampleData()
                            } label: {
                                Label("ADD SAMPLES", systemImage: "list.bullet")
                            }
                        }
                        ToolbarItem {
                            Button {
                                viewModel.persistenceController.deleteAll()
                                viewModel.removeAllNotifications()
                            } label: {
                                Label("DELETE SAMPLES", systemImage: "trash")
                            }
                        }
#endif
                    }
                    .onAppear {
                        viewModel.checkAndResetStreaks()
                    }
                }
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    ContentView(persistenceController: .preview)
        .environmentObject(persistenceController)
}
