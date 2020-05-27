//
//  Todo + Convenience.swift
//  WunderList
//
//  Created by Joe Veverka on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation
import CoreData

extension Todo {
    // MARK: - Properties
    var todoRepresentation: TodoRepresentation? {

        // Grabbing locationRep property made in 'Location' extension below
        let locationRep = Location()
        guard let representedLocation = locationRep.locationRepresentation else { return  nil }

        guard let identifier = identifier,
        let title = title,
        let body = body,
        let dueDate = dueDate else { return nil }
        return TodoRepresentation(
            identifier: identifier,
            title: title,
            body: body,
            dueDate: dueDate,
            complete: complete,
            recurring: .none,
            location: representedLocation
        )
    }

    // MARK: - Convenience Inits
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        body: String,
                                        dueDate: Date = Date(),
                                        complete: Bool = false,
                                        recurring: String,
                                        user: User,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.user = user
        self.identifier = identifier
        self.title = title
        self.body = body
        self.dueDate = dueDate
        self.recurring = recurring
    }

// MARK: - WHERE I'M STUCK (relationship issues I beleive)
    @discardableResult convenience init?(
        todoRepresentation: TodoRepresentation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext,
        userRep: UserRepresentation
    ) {
       guard let user = User(userRep: userRep) else { return nil }

        self.init(
            identifier: todoRepresentation.identifier,
            title: todoRepresentation.title,
            body: todoRepresentation.body,
            dueDate: todoRepresentation.dueDate,
            recurring: todoRepresentation.recurring.rawValue,
            user: user,
            context: context
        )

    }
}
extension Location {

    var locationRepresentation: LocationRepresentation? {
        let xCoord = xLocation
        let yCoord = yLocation

        return LocationRepresentation(xLocation: xCoord, yLocation: yCoord)
    }
}
