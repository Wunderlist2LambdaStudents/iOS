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
            creatorId: user?.identifier ?? UUID()
        )
    }

    // MARK: - Convenience Inits
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        body: String,
                                        dueDate: Date = Date(),
                                        complete: Bool,
                                        recurring: String,
                                        user: User,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.user = user
        self.identifier = identifier
        self.title = title
        self.body = body
        self.dueDate = dueDate
        self.complete = complete
        self.recurring = recurring
    }

    @discardableResult convenience init?(
        todoRepresentation: TodoRepresentation,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext,
        userRep: UserRepresentation
    ) {
        //used to establish relationship
        guard let user = User(userRep: userRep, context: context),
            let userContext = user.managedObjectContext
        else { return nil }

        self.init(context: userContext)
        identifier = todoRepresentation.identifier
        title = todoRepresentation.title
        body = todoRepresentation.body
        dueDate = todoRepresentation.dueDate
        complete = todoRepresentation.complete
        recurring = todoRepresentation.recurring.rawValue
        self.user = user
    }
}

extension Location {
    @discardableResult convenience init(
        identifier: UUID = UUID(),
        xLocation: Double,
        yLocation: Double,
        todo: Todo,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.xLocation = xLocation
        self.yLocation = yLocation
        //establishes relationship
        self.todo = todo
    }

    var locationRepresentation: LocationRepresentation? {
        let xCoord = xLocation
        let yCoord = yLocation

        return LocationRepresentation(xLocation: xCoord, yLocation: yCoord)
    }
}
