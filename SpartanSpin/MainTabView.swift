//
//  MainTabView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var viewModel: ViewModel
    
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
                    VStack {
                        CalendarView(selectedDate: $viewModel.selectedDate)
                            .frame(height: 400)
                        Spacer()
                    }
                }
                .navigationDestination(isPresented: $viewModel.showingDetail) {
                    if let selectedDate = viewModel.selectedDate {
                        GoalsForDateView(date: selectedDate)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
                .onChange(of: viewModel.selectedDate) { _, newValue in
                    viewModel.showingDetail = (newValue != nil)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Spartan Spin")
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                    }
                }
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tint(colorScheme == .dark ? .white : .black)    }
}

#Preview {
    let persistenceController = PersistenceController()

    MainTabView(persistenceController: .preview)
}
