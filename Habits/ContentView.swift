//
//  ContentView.swift
//  Habits
//
//  Created by Brendan Caporale on 3/1/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Habit.timestamp,
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
                        Text("Item at \(habit.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(habit.timestamp!, formatter: itemFormatter)
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
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Habit(context: viewContext)
            newItem.timestamp = Date()
            
            try? viewContext.save()
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = habits[offset]
            persistanceController.delete(item)
        }
        
        try? viewContext.save()
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
