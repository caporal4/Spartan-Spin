//
//  HabitsApp.swift
//  Habits
//
//  Created by Brendan Caporale on 3/1/25.
//

import SwiftUI

@main
struct HabitsApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                ContentView(persistanceController: .preview)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } detail: {
                HabitView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(persistenceController)
            .onChange(of: scenePhase, initial: false) { phase, _  in
                if phase != .active {
                    persistenceController.save()
                }
            }
        }
    }
}
