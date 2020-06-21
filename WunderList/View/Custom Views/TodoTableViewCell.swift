//
//  TodoTableViewCell.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!

    // MARK: - Properties

    var todoController = TodoController()

    var todoRep: TodoRepresentation? {
        didSet {
            updateViews()
        }
    }

    private var todo: Todo?

    // MARK: - Class Methods
    func updateViews() {
        guard let todo = todoRep else { return }

        todoTitleLabel.text = todo.title

        completeButton.setImage(todo.complete ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)
    }

    // MARK: - Actions

    @IBAction func completeButtonToggle(_ sender: UIButton) {
        fetchCoreDataTodo()

        guard let todoRep = todoRep else { return }
        self.todoRep?.complete.toggle()
        self.todo?.complete.toggle()
        try? CoreDataStack.shared.save()
        
        sender.setImage(todoRep.complete ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)

        todoController.sendTodosToServer(todo: todoRep)

    }

    private func fetchCoreDataTodo() {
        guard let identifier = todoRep?.identifier else { return }
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        //        //There's one in CoreData that isn't on the server.
        do {
            let existingTodos = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            self.todo = existingTodos.first
        } catch {
            print("error fetching Todo: \(error)")
        }
    }
}
