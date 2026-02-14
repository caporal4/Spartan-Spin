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
                Label("Goals", systemImage: "list.bullet")
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
                .navigationDestination(
                    isPresented: Binding(
                        get: { viewModel.selectedDate != nil },
                        set: { if !$0 { viewModel.selectedDate = nil } }
                    )
                ) {
                    if let date = viewModel.selectedDate {
                        DailyAndWeeklyRecordList(date: date, timeline: "Daily")
                            .modifier(HideTabBarIfAvailable())
                            .onDisappear {
                                viewModel.selectedDate = nil
                            }
                    }
                }
                // Navigation destination for weeks
                .navigationDestination(for: Date.self) { date in
                    let components = Calendar.current.dateComponents(
                        [.year, .month, .day],
                        from: date
                    )
                    DailyAndWeeklyRecordList(date: components, timeline: "Weekly")
                        .modifier(HideTabBarIfAvailable())
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Spartan Spin")
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                    }
                }
                .toolbarBackground(Colors.spartanSpinGreen.opacity(0.3), for: .tabBar)
            }
            .tag(1)
            .tabItem {
                Label("Progress", systemImage: "calendar")
            }
        }
        .onChange(of: viewModel.selectedTab) { newValue in
            if newValue == 0 && viewModel.previousTab != 0 {
                viewModel.displayedMonth = Date.now
            }
            viewModel.previousTab = newValue
        }
        .environmentObject(viewModel)
        .tabViewStyle(.automatic)
        .tint(colorScheme == .dark ? .white : .black)
    }
}

#Preview {
    MainTabView(persistenceController: .preview)
}
