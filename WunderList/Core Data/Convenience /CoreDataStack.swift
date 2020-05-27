//
//  File.swift
//  WunderList
//
//  Created by Joe Veverka on 5/23/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    // MARK: - Properties
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WunderList")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                context.reset()
                error = saveError
            }
        }
        if let error = error {throw error}
    }
}
