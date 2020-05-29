//
//  TodoListViewController.swift
//  WunderList
//
//  Created by Kenny on 5/25/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController {
    // MARK: - Properties

    var complete = false
    let todoController = TodoController()

    lazy var fetchedResultsController: NSFetchedResultsController<Todo> = {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        if AuthService.activeUser != nil {
            guard let userId = AuthService.activeUser?.identifier?.uuidString else {
                fatalError("Identifier error")
            }
            let predicate = NSPredicate(format: "userId == %@", userId)
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "complete", ascending: true),
                                        NSSortDescriptor(key: "dueDate", ascending: true)]
        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "recurring",
            cacheName: nil
        )
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            NSLog("Error performing initial fetch inside fetchedResultsController: \(error)")
        }
        return frc
    }()

    // Quick Dummy data
    var nonRecurringTodos = AuthService.activeUser?.todos?.filter { $0.recurring == .none }
    var dailyTodos = AuthService.activeUser?.todos?.filter { $0.recurring == .daily }
    var weeklyTodos = AuthService.activeUser?.todos?.filter { $0.recurring == .weekly }
    var monthlyTodos = AuthService.activeUser?.todos?.filter { $0.recurring == .monthly }

    // MARK: - Outlets -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoBodyTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateViews() {
        let todoController = TodoController()
        guard let user = todoController.loadMockUser() else { return }
        AuthService.activeUser = user
        todoController.fetchTodosFromServer { _ in
            try? self.fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        /*
         To load mock Todos:
         todoController.loadMockTodos(from: &user)
         guard let todos = user.todos else { return }
         todoController.sendTodosToServer(todo: todos[1])
         */
    }

    @IBAction func completeButton(_ sender: UIButton) {
        complete.toggle()

        sender.setImage(complete ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // You needed a separate segue to make edit work properly
        // (a new segue from the cell to the vc with it's own identifier).
        // The add segue wasnt working for adding because indexPath was nil
        if let todoEditVC = segue.destination as? TodoEditAndAddViewController {
            if segue.identifier == "EditTaskSegue" {
                guard let indexPath = tableView.indexPathForSelectedRow else { return }
                todoEditVC.todo = fetchedResultsController.object(at: indexPath)
                todoEditVC.todoController = todoController
            } else if segue.identifier == "AddTaskSegue" {
                todoEditVC.todoController = todoController
            }
        }
    }
}

// MARK: - TableView Methods

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodoCell",
            for: indexPath
            ) as? TodoTableViewCell
            else { return UITableViewCell() }

        guard let todo = fetchedResultsController
            .sections?[indexPath.section]
            .objects?[indexPath.row] as? Todo else { return UITableViewCell() }
        cell.todoTitleLabel.text = todo.title

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return nil
        }
        return sectionInfo.name.capitalized
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let todo = fetchedResultsController.object(at: indexPath)
            guard let todoRep = todo.todoRepresentation else { return }
            todoController.deleteTodosFromServer(todo: todoRep) { result in
                let result = try? result.get()
                if result == nil {
                    return
                }
                //save changes only if it deleted from the server
                todo.recurring = "deleted"
                DispatchQueue.main.async {
                    let context = CoreDataStack.shared.mainContext
                    do {
                        try context.save()
                    } catch {
                        context.reset()
                        NSLog("Error saving managed object context (delete task): \(error)")
                    }
                }
            }
        }
    }
}

extension TodoListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            break
        @unknown default:
            break
        }
    }
}
