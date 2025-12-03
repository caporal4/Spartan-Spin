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
    
    func isMonthlyMoveActive(string: String, goals: [Goal]) -> Bool {
        let normalizedMonthlyMove = string
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return goals.contains { goal in
            let normalizedGoalTitle = goal.goalTitle
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if normalizedGoalTitle == normalizedMonthlyMove {
                return true
            }
            
            if normalizedGoalTitle.contains(normalizedMonthlyMove) ||
               normalizedMonthlyMove.contains(normalizedGoalTitle) {
                return true
            }
            
            return levenshteinDistance(normalizedGoalTitle, normalizedMonthlyMove) <= 2
        }
    }
    
    private func levenshteinDistance(_ stringOne: String, _ stringTwo: String) -> Int {
        let stringOne = Array(stringOne)
        let stringTwo = Array(stringTwo)
        var dist = Array(repeating: Array(repeating: 0, count: stringTwo.count + 1), count: stringOne.count + 1)
        
        for count in 0...stringOne.count { dist[count][0] = count }
        for count in 0...stringTwo.count { dist[0][count] = count }
        
        for countOne in 1...stringOne.count {
            for countTwo in 1...stringTwo.count {
                if stringOne[countOne-1] == stringTwo[countTwo-1] {
                    dist[countOne][countTwo] = dist[countOne-1][countTwo-1]
                } else {
                    dist[countOne][countTwo] = min(dist[countOne-1][countTwo],
                                                   dist[countOne][countTwo-1],
                                                   dist[countOne-1][countTwo-1]) + 1
                }
            }
        }
        
        return dist[stringOne.count][stringTwo.count]
    }
}
