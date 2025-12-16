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
                            if viewModel.isLoadingMove {
                                ProgressView()
                            } else {
                                if let currentMove = viewModel.currentMove {
                                    Button(action: viewModel.showNewGoalViewMonthlyMove) {
                                        MonthlyMoveButton(
                                            monthlyMove: currentMove.move,
                                            failedToLoad: viewModel.failedToLoad,
                                            count: viewModel.goals.count
                                        )
                                    }
                                    .accessibilityIdentifier("Move of the Month")
                                    .padding()
                                } else {
                                    Button {
                                        Task { await viewModel.fetchMoveOfTheMonth() }
                                    } label: {
                                        MonthlyMoveButton(
                                            monthlyMove: "Failed to load",
                                            failedToLoad: viewModel.failedToLoad,
                                            count: nil
                                        )
                                    }
                                    .accessibilityIdentifier("Move of the Month")
                                    .padding()
                                }
                            }
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
                } else {
                    VStack(spacing: 0) {
                        List {
                            GoalSectionView(
                                title: "Daily Goals",
                                goals: viewModel.goals.dailyGoals,
                                onDelete: viewModel.dailySwipeToDelete,
                                reloadData: viewModel.reloadData
                            )
                            GoalSectionView(
                                title: "Weekly Goals",
                                goals: viewModel.goals.weeklyGoals,
                                onDelete: viewModel.weeklySwipeToDelete,
                                reloadData: viewModel.reloadData
                            )
                            GoalSectionView(
                                title: "Monthly Goals",
                                goals: viewModel.goals.monthlyGoals,
                                onDelete: viewModel.monthlySwipeToDelete,
                                reloadData: viewModel.reloadData
                            )
                        }
                        .scrollContentBackground(.hidden)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            Group {
                                if viewModel.isLoadingMove {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: 45)
                                } else {
                                    if let monthlyMove = viewModel.currentMove {
                                        let matchGoals = viewModel.persistenceController.findMatchingMonthlyMoveGoals(
                                            monthlyMoveTitle: monthlyMove.move,
                                            goals: viewModel.goals
                                        )
                                        if viewModel.persistenceController.isMonthlyMoveActive(
                                            string: monthlyMove.move,
                                            goals: viewModel.goals
                                        ) {
                                            // monthly move is equal to a goal, find out how many
                                            if matchGoals.count == 1 {
                                                // one active goal with it
                                                NavigationLink(value: matchGoals[0]) {
                                                        MonthlyMoveButton(
                                                            monthlyMove: monthlyMove.move,
                                                            failedToLoad: viewModel.failedToLoad,
                                                            count: matchGoals.count
                                                        )
                                                        .padding([.horizontal, .bottom])
                                                    }
                                                .accessibilityIdentifier("Move of the Month")
                                            } else if matchGoals.count > 1 {
                                                // multiple active goals with it
                                                Button(action: viewModel.showMonthlyMoveList) {
                                                        MonthlyMoveButton(
                                                            monthlyMove: monthlyMove.move,
                                                            failedToLoad: viewModel.failedToLoad,
                                                            count: matchGoals.count
                                                        )
                                                        .padding([.horizontal, .bottom])
                                                    }
                                                .accessibilityIdentifier("Move of the Month")
                                            }
                                        } else {
                                            // no active goal with it
                                            Button(action: viewModel.showNewGoalViewMonthlyMove) {
                                                MonthlyMoveButton(
                                                    monthlyMove: monthlyMove.move,
                                                    failedToLoad: viewModel.failedToLoad,
                                                    count: matchGoals.count
                                                )
                                            }
                                            .accessibilityIdentifier("Move of the Month")
                                            .padding([.horizontal, .bottom])
                                        }
                                    } else {
                                        // monthly move failed to load
                                        Button {
                                            Task { await viewModel.fetchMoveOfTheMonth() }
                                        } label: {
                                            MonthlyMoveButton(
                                                monthlyMove: nil,
                                                failedToLoad: viewModel.failedToLoad,
                                                count: nil
                                            )
                                        }
                                        .accessibilityIdentifier("Move of the Month")
                                        .padding([.horizontal, .bottom])
                                    }
                                }
                            }
                        }
                    }
                    .background(Colors.gradientC.ignoresSafeArea())
                    .contentViewToolbar(
                        showNewGoalView: viewModel.showNewGoalView,
                        createSampleData: viewModel.persistenceController.createSampleData,
                        deleteAll: viewModel.persistenceController.deleteAll,
                        removeAllNotifications: {
                            viewModel.persistenceController.removeMultipleReminders(viewModel.goals)
                        }
                    )
                    .toolbarBackground(Colors.spartanSpinGreen.opacity(0.3), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
                }
            }
            .onAppear {
                viewModel.checkAndResetStreaks()
            }
            .task {
                await viewModel.fetchMoveOfTheMonth()
            }
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
                    title: viewModel.currentMove?.move ?? "",
                    unit: "Repitition",
                    persistenceController: viewModel.persistenceController
                )
            }
            .sheet(isPresented: $viewModel.multipleGoalsWithMonthlyMove) {
                if let monthlyMove = viewModel.currentMove {
                    let matchGoals = viewModel.persistenceController.findMatchingMonthlyMoveGoals(
                        monthlyMoveTitle: monthlyMove.move,
                        goals: viewModel.goals
                    )
                    MonthlyMoveListView(
                        persistenceController: viewModel.persistenceController,
                        move: monthlyMove.move,
                        goals: matchGoals
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView(persistenceController: .preview)
}
