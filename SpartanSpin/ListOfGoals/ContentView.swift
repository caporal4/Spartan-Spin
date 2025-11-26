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
                if viewModel.goals.isEmpty {
                    ZStack {
                        Colors.gradientC
                            .ignoresSafeArea()
                        VStack {
                            Text("Create a new goal!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.spartanSpinGreen)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: viewModel.showNewGoalView) {
                                Label("Add Goal", systemImage: "plus.app")
                                    .font(.headline)
                                    .padding()
                                    .background(Colors.spartanSpinGreen.opacity(Numbers.newGoalOpacity))
                                    .cornerRadius(Numbers.newGoalCornerRadius)
                            }
                            .tint(colorScheme == .dark ? .white : .black)
#if DEBUG
                            Button(action: viewModel.persistenceController.createSampleData) {
                                Label("Add Sample Goals", systemImage: "plus.app")
                                    .font(.headline)
                                    .padding()
                                    .background(Colors.spartanSpinGreen.opacity(Numbers.newGoalOpacity))
                                    .cornerRadius(Numbers.newGoalCornerRadius)
                            }
                            .tint(colorScheme == .dark ? .white : .black)
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
                    .sheet(isPresented: $viewModel.newGoal) {
                        NewGoalView(persistenceController: viewModel.persistenceController)
                    }
                } else {
                    List {
                        if !viewModel.goals.dailyGoals.isEmpty {
                            Section("Daily Goals") {
                                ForEach(viewModel.goals.dailyGoals) { goal in
                                    NavigationLink(value: goal) {
                                        ZStack(alignment: .leading) {
                                            ContentViewRectangle()
                                            ContentViewRow(goal: goal)
                                        }
                                    }
                                    .listRowBackground(Colors.spartanSpinGreen)
                                    .onReceive(goal.objectWillChange) { _ in
                                        viewModel.reloadData()
                                    }
                                    .accessibilityIdentifier(goal.goalTitle)
                                }
                                .onDelete(perform: viewModel.dailySwipeToDelete)
                            }
                        }
                        if !viewModel.goals.weeklyGoals.isEmpty {
                            Section("Weekly Goals") {
                                ForEach(viewModel.goals.weeklyGoals) { goal in
                                    NavigationLink(value: goal) {
                                        ZStack(alignment: .leading) {
                                            ContentViewRectangle()
                                            ContentViewRow(goal: goal)
                                        }
                                    }
                                    .listRowBackground(Colors.spartanSpinGreen)
                                    .onReceive(goal.objectWillChange) { _ in
                                        viewModel.reloadData()
                                    }
                                    .accessibilityIdentifier(goal.goalTitle)
                                }
                                .onDelete(perform: viewModel.weeklySwipeToDelete)
                            }
                        }
                        if !viewModel.goals.monthlyGoals.isEmpty {
                            Section("Monthly Goals") {
                                ForEach(viewModel.goals.monthlyGoals) { goal in
                                    NavigationLink(value: goal) {
                                        ZStack(alignment: .leading) {
                                            ContentViewRectangle()
                                            ContentViewRow(goal: goal)
                                        }
                                    }
                                    .listRowBackground(Colors.spartanSpinGreen)
                                    .onReceive(goal.objectWillChange) { _ in
                                        viewModel.reloadData()
                                    }
                                    .accessibilityIdentifier(goal.goalTitle)
                                }
                                .onDelete(perform: viewModel.monthlySwipeToDelete)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Colors.gradientC)
                    .navigationDestination(for: Goal.self) { goal in
                        GoalView(goal: goal, persistenceController: viewModel.persistenceController)
                            .toolbar(.hidden, for: .tabBar)
                    }
                    .sheet(isPresented: $viewModel.newGoal) {
                        NewGoalView(persistenceController: viewModel.persistenceController)
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Spartan Spin")
                                .font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                        }
                        ToolbarItem {
                            Button(action: viewModel.showNewGoalView) {
                                Label("Add Goal", systemImage: "plus.app")
                            }
                            .tint(colorScheme == .dark ? .white : .black)

                        }
#if DEBUG
                        ToolbarItem {
                            Button {
                                viewModel.persistenceController.createSampleData()
                            } label: {
                                Label("ADD SAMPLES", systemImage: "list.bullet")
                            }
                            .tint(colorScheme == .dark ? .white : .black)

                        }
                        ToolbarItem {
                            Button {
                                viewModel.persistenceController.deleteAll()
                                viewModel.removeAllNotifications()
                            } label: {
                                Label("DELETE SAMPLES", systemImage: "trash")
                            }
                            .tint(colorScheme == .dark ? .white : .black)

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
