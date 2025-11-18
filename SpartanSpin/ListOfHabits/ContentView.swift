//
//  ContentView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel: ViewModel
    
    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(selection: $viewModel.persistenceController.selectedHabit) {
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
            .navigationTitle("Spartan Spin")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Habit.self) { item in
                DetailView(habit: item)
            }
            .sheet(isPresented: $viewModel.newHabit) {
                NewHabitView(persistenceController: viewModel.persistenceController)
            }
            .toolbar {
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
                viewModel.launchApp()
            }
            .tint(.white)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    ContentView(persistenceController: .preview)
        .environmentObject(persistenceController)
}
