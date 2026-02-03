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
        TabView(selection: $viewModel.selectedTab) {
            NavigationStack {
                ContentView(persistenceController: viewModel.persistenceController)
            }
            .tag(0)
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            NavigationStack {
                ZStack {
                    Colors.gradientC
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            HStack {
                                Text("Daily Goals")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                Spacer()
                            }
                            HStack {
                                Button {
                                    viewModel.calculateNewDate(
                                        of: viewModel.displayedMonth,
                                        amount: -1
                                    )
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundStyle(.white)
                                }
                                .padding(.leading)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.showingMonthPicker.toggle()
                                } label: {
                                    Text(viewModel.monthTitle)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.calculateNewDate(
                                        of: viewModel.displayedMonth,
                                        amount: 1
                                    )
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white)
                                }
                    
                                .padding(.trailing)
                            }
                            if viewModel.showingMonthPicker {
                                MonthYearPicker(selectedDate: $viewModel.displayedMonth)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal)
                            }
                            MonthCalendarView(
                                displayedMonth: viewModel.displayedMonth,
                                selectedDate: $viewModel.selectedDate
                            )
                        }
                        VStack {
                            HStack {
                                Text("Weekly Goals")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                Spacer()
                            }
                            WeekProgressView(month: viewModel.displayedMonth)
                        }
                        VStack {
                            HStack {
                                Text("Monthly Goals")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                Spacer()
                            }
                            MonthlyRecordList(timeline: "Monthly")
                                .padding()
                        }
                    }
                    .padding(.top, -50)
                    .scrollIndicators(.never)
                }
                // Navigation destination for individual dates
                .navigationDestination(item: $viewModel.selectedDate) { date in
                    DailyAndWeeklyRecordList(date: date, timeline: "Daily")
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
                    DailyAndWeeklyRecordList(date: components, timeline: "Weekly")
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
            .tag(1)
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
        }
        .onChange(of: viewModel.selectedTab) { oldValue, newValue in
            if newValue == 0 && oldValue != 0 {
                viewModel.displayedMonth = Date.now
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
