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
            sectionNameKeyPath: nil,
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

    @IBOutlet weak var switchTableViewSegmentedControlAction: UISegmentedControl!
    var currentSelectedSegment = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        switchTableViewSegmentedControlAction.backgroundColor = #colorLiteral(red: 0.3939243257, green: 0.3406436443, blue: 0.820184648, alpha: 0.7223886986)
        switchTableViewSegmentedControlAction.selectedSegmentTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        todoTitle.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.8080318921)
    }

    func updateViews() {
        let todoController = TodoController()
        guard let user = todoController.loadMockUser() else { return }
        AuthService.activeUser = user
        todoController.fetchTodosFromServer()
        /*
         To load mock Todos:
         todoController.loadMockTodos(from: &user)
         guard let todos = user.todos else { return }
         todoController.sendTodosToServer(todo: todos[1])
         */
    }

    @IBAction func completeButton(_ sender: UIButton) {
        complete.toggle()
        sender.setImage(complete ? UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)
    }

    @IBAction func switchTableViewSegmentedControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentSelectedSegment = 1
        } else if sender.selectedSegmentIndex == 1 {
            currentSelectedSegment = 2
        } else if sender.selectedSegmentIndex == 2 {
            currentSelectedSegment = 3
        }
        self.tableView.reloadData()

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
            } else if segue.identifier == "AddTaskSegue" {
                todoEditVC.todoController = todoController
            }
        }
    }
}

// MARK: - TableView Methods

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSelectedSegment == 1 {
            return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        } else if currentSelectedSegment == 2 {
            return fetchedResultsController.sections?[1].numberOfObjects ?? 0
        } else {
            return fetchedResultsController.sections?[2].numberOfObjects ?? 0
        }
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

                DispatchQueue.main.async {
                    let context = CoreDataStack.shared.mainContext

                    context.delete(todo)
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
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
