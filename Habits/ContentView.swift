//
//  ContentView.swift
//  Habits
//
//  Created by Brendan Caporale on 3/1/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Habit.title,
            ascending: true
        )],
        animation: .default)
    
    private var habits: FetchedResults<Habit>
    
    var persistanceController: PersistenceController

    var body: some View {
        NavigationView {
            List {
                ForEach(habits) { habit in
                    NavigationLink {
                        Text("\(habit.habitTitle)")
                    } label: {
                        Text(habit.habitTitle)
                    }
                }
                .onDelete(perform: delete)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: persistanceController.addHabit) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
#if DEBUG
                ToolbarItem {
                    Button {
                        persistanceController.createSampleData()
                    } label: {
                        Label("ADD SAMPLES", systemImage: "flame")
                    }
                }
                ToolbarItem {
                    Button {
                        persistanceController.deleteAll()
                    } label: {
                        Label("DELETE SAMPLES", systemImage: "pencil")
                    }
                }
#endif
            }
            Text("Select a habit")
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = habits[offset]
            persistanceController.delete(item)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView(persistanceController: .preview).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
