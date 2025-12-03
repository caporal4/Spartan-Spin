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
                            Spacer()
                            Spacer()
                            Spacer()
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
                            Spacer()
                            Spacer()
                            Button(action: viewModel.showNewGoalViewMonthlyMove) {
                                MonthlyMoveButton(monthlyMove: viewModel.monthlyMove)
                            }
                            .accessibilityIdentifier("Move of the Month")
                            .padding()
                            Spacer()
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
                        NewGoalView(title: "", unit: "No Unit", persistenceController: viewModel.persistenceController)
                    }
                    .sheet(isPresented: $viewModel.newGoalMonthlyMove) {
                        NewGoalView(
                            title: viewModel.monthlyMove,
                            unit: "Repitition",
                            persistenceController: viewModel.persistenceController
                        )
                    }
                } else {
                    VStack(spacing: 0) {
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
                            NewGoalView(
                                title: "",
                                unit: "No Unit",
                                persistenceController: viewModel.persistenceController
                            )
                        }
                        .sheet(isPresented: $viewModel.newGoalMonthlyMove) {
                            NewGoalView(
                                title: viewModel.monthlyMove,
                                unit: "Repitition",
                                persistenceController: viewModel.persistenceController
                            )
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
                        .toolbarBackground(Colors.spartanSpinGreen.opacity(0.3), for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                        if !viewModel.persistenceController.isMonthlyMoveActive(
                            string: viewModel.monthlyMove,
                            goals: viewModel.goals
                        ) {
                            Button(action: viewModel.showNewGoalViewMonthlyMove) {
                                MonthlyMoveButton(monthlyMove: viewModel.monthlyMove)
                            }
                            .accessibilityIdentifier("Move of the Month")
                            .padding([.horizontal, .bottom])
                            .background(Colors.spartanSpinGreen)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(persistenceController: .preview)
}
