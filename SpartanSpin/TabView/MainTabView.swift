//
//  MainTabView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel: ViewModel
    
    init(persistenceController: PersistenceController) {
        let viewModel = ViewModel(persistenceController: persistenceController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                ContentView(persistenceController: viewModel.persistenceController)
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            NavigationStack {
                ZStack {
                    Colors.gradientC
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            MonthCalendarView(selectedDate: $viewModel.selectedDate)
                                .frame(height: 400)
                            Divider()
                            WeekProgressView()
                            Divider()
                            MonthProgressView(goals: viewModel.goals)
                                .padding()
                        }
                    }
                    .scrollIndicators(.never)
                }
                // Navigation destination for individual dates
                .navigationDestination(item: $viewModel.selectedDate) { date in
                        GoalsForDateView(date: date, recordsForDate: viewModel.goalRecords)
                            .toolbar(.hidden, for: .tabBar)
                            .onDisappear {
                                viewModel.selectedDate = nil
                            }
                }
                // Navigation destination for weeks
                .navigationDestination(for: Date.self) { date in
                    let components = Calendar.current.dateComponents(
                        [.year, .month, .day],
                        from: date
                    )
                    GoalsForDateView(date: components, recordsForDate: viewModel.goalRecords)
                        .toolbar(.hidden, for: .tabBar)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Spartan Spin")
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                    }
                }
                .toolbarBackground(Colors.spartanSpinGreen.opacity(0.3), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
        }
        .environmentObject(viewModel)
        .tabViewStyle(.automatic)
        .toolbarVisibility(.visible, for: .tabBar)
        .tint(colorScheme == .dark ? .white : .black)
        .persistentSystemOverlays(.hidden) 
    }
}

#Preview {
    MainTabView(persistenceController: .preview)
}
