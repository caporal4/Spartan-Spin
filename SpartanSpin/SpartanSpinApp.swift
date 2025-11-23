//
//  SpartanSpinApp.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

@main
struct SpartanSpinApp: App {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    ContentView(persistenceController: persistenceController)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(persistenceController)
                        .onChange(of: scenePhase, initial: false) { phase, _  in
                            if phase != .active {
                                persistenceController.save()
                            }
                        }
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                NavigationStack {
                    CalendarView()
                }
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            }
            .tabViewStyle(.tabBarOnly)
            .tint(colorScheme == .dark ? .white : .black)
        }
    }
}
