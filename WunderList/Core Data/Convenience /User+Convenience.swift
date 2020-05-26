//
//  User+Convenience.swift
//  WunderList
//
//  Created by Kenny on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation
import CoreData

extension User {

    @discardableResult convenience init(
        username: String,
        identifier: UUID,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.username = username
        self.identifier = identifier
    }

    @discardableResult convenience init?(
        userRep: UserRepresentation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        guard let identifier = UUID(uuidString: userRep.identifier ?? "") else { return nil }
        self.init(
            username: userRep.username,
            identifier: identifier,
            context: context
        )
    }

}
