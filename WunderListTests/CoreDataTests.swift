//
//  CoreDataTests.swift
//  WunderListTests
//
//  Created by Kenny on 5/30/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import XCTest
@testable import WunderList

class CoreDataTests: XCTestCase {
    let userRep = WunderListTests.UserRepresentation(
        username: "Kenny", password: nil,
        identifier: UUID(),
        token: "KennyToken"
    )
    let bgContext = CoreDataStack.shared.container.newBackgroundContext()
    lazy var user = WunderListTests.User(userRep: userRep, context: bgContext)
    lazy var todoRep = WunderListTests.TodoRepresentation(
        identifier: UUID(),
        title: "Test Creating Todo From TodoRep",
        body: "Hopefully this works",
        dueDate: Date(),
        complete: false,
        recurring: .daily,
        location: nil,
        creatorId: user?.identifier ?? UUID()
    )
    lazy var todo = WunderListTests.Todo(
        todoRepresentation: todoRep,
        context: bgContext,
        userRep: userRep
        )

    func testTodoRepInit() {
        //`Todo(todoRep ...` init is failable
        XCTAssertNotNil(todo)
        //having problem with contexts
        XCTAssertEqual(user?.managedObjectContext, bgContext)
        XCTAssertEqual(todo?.managedObjectContext, bgContext)
        XCTAssertEqual(todo?.managedObjectContext, user?.managedObjectContext)
        //check properties
        XCTAssertEqual(todoRep.title, todo?.title)
        XCTAssertEqual(todoRep.identifier, todo?.identifier)
        XCTAssertEqual(todoRep.body, todo?.body)
        XCTAssertEqual(todoRep.dueDate, todo?.dueDate)
        XCTAssertEqual(todoRep.complete, todo?.complete)
        XCTAssertEqual(todoRep.recurring, Recurring(rawValue: (todo?.recurring)!)!)
        XCTAssertNil(todoRep.location)
        XCTAssertEqual(todoRep.creatorId, user?.identifier)
        XCTAssertNotEqual(todoRep.identifier, user?.identifier)
        do {
        XCTAssertNoThrow(try CoreDataStack.shared.save())
        }
        let mover = CoreDataMover()
        mover.todo = todo
        XCTAssertNotNil(mover.todo)
        XCTAssertEqual(mover.todo, todo)
        mover.todoModifyAndSave()
        print(mover.todo?.title)
        XCTAssertEqual(mover.todo!.title, "Test Creating Todo From TodoRep modified")
    }

    func testTodoCompleteChanges() {

    }

    class CoreDataMover {
        var todo: Todo?
        func todoModifyAndSave() {
            guard let todo = todo else { return }
            todo.title = "\(todo.title) modified"
            try? CoreDataStack.shared.save()
        }
    }

}
