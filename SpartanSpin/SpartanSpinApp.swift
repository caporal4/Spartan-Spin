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
            TabView {
                Tab("List", systemImage: "list.bullet") {
                    ContentView(persistenceController: persistenceController)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(persistenceController)
                        .onChange(of: scenePhase, initial: false) { phase, _  in
                            if phase != .active {
                                persistenceController.save()
                            }
                        }
                }
                Tab("Calendar", systemImage: "calendar") {
                    CalendarView()
                }
            }
            .tint(.black)
        }
    }
}
