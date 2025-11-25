//
//  Persistence.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import CoreData
import UserNotifications
import SwiftUI

class PersistenceController: ObservableObject {
    let container: NSPersistentContainer
    
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
    
    @Published var selectedGoal: Goal?
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Goal", managedObjectModel: Self.model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
 #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
 #endif
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static let preview: PersistenceController = {
        let persistanceController = PersistenceController(inMemory: true)
        persistanceController.createSampleData()
        return persistanceController
    }()
    
    func createSampleData() {
        let viewContext = container.viewContext
        
        let availableGoal = ["Brush Teeth", "Floss", "Feed Dog", "Walk Dog", "Take Medicine", "Make Bed"]
        let timelines = ["Daily", "Weekly", "Monthly", "Daily", "Weekly"]
        for int in 0...4 {
            let newGoal = Goal(context: viewContext)
            newGoal.id = UUID()
            newGoal.title = availableGoal[int]
            newGoal.unit = "No Unit"
            newGoal.timeline = timelines[int]
            newGoal.lastStreakReset = Date.now
            newGoal.lastTaskReset = Date.now
            newGoal.tasksNeeded = 2
        }
        
        try? viewContext.save()
    }
    
    func save() {
        try? container.viewContext.save()
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        save()
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Goal.fetchRequest()
        delete(request1)

        save()
    }
    
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "SpartanSpin", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
}
