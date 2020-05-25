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
        let container = NSPersistentContainer(name: "Movie")
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
}
