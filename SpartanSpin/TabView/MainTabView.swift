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
                    Text("Calendar View Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.spartanSpinGreen)
                        .multilineTextAlignment(.center)
                        .padding()
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
        .tabViewStyle(.automatic)
        .toolbarVisibility(.visible, for: .tabBar)
        .tint(colorScheme == .dark ? .white : .black)
        .persistentSystemOverlays(.hidden) 
    }
}

#Preview {
    MainTabView(persistenceController: .preview)
}
