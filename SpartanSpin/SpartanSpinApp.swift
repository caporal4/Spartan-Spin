//
//  SpartanSpinApp.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

@main
struct SpartanSpinApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                ContentView(persistenceController: persistenceController)
            } detail: {
                DetailView(habit: persistenceController.selectedHabit)
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
