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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "complete", ascending: true),
                                        NSSortDescriptor(key: "title", ascending: true)]
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
    var dailyTodo = ["Walk The Dog", "walk the Dog again"]
    var weeklyTodo = ["Pick Up Dog", "Feed Dog"]
    var monthlyTodo = ["Eat dog", "walk the dog again"]
    
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
        //update the view after the user is logged in or create mock user
        if AuthService.activeUser != nil {
            todoController.fetchTodosFromServer { (result) in
                print(try? result.get())
            }
        } else {
            print("no active user, mocking user:")
            let todoController = TodoController()
            guard var user = todoController.loadMockUser() else { return }
            todoController.loadMockTodos(from: &user)
            AuthService.activeUser = user
            todoController.loadMockTodos(from: &user)
            print(user.todos)
            
            //CoreData works with relationships
            
            //            let todoRepresentation = TodoRepresentation(
            //                identifier: UUID(),
            //                title: "Test Append",
            //                body: "Testing",
            //                dueDate: Date(),
            //                complete: true,
            //                recurring: .none,
            //                location: LocationRepresentation(xLocation: 0, yLocation: 0)
            //            )
            //            guard let coreDataUser = User(userRep: user) else { return }
            //            let todo = Todo(identifier: UUID(), title: "title",
            //            body: "body", dueDate: Date(), complete: true, recurring: "none",
            //            user: coreDataUser, context: CoreDataStack.shared.mainContext)
            //            Location(identifier: UUID(), xLocation: 20.0, yLocation: 25.2, todo: todo,
            //            context: CoreDataStack.shared.mainContext)
            //            print(coreDataUser.todo)
        }
    }
    
    @IBAction func completeButton(_ sender: UIButton) {
        complete.toggle()
        
        sender.setImage(complete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
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
        
        if segue.identifier == "AddTaskSegue" {
            if let todoEditVC = segue.destination as?
                TodoEditAndAddViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                // line 121 is not working because we have to insert a todo data model object into the todoEditVC..
                // todoEditVC.todo = fetchedResultsController.object(at: indexPath)
                todoEditVC.todoController = todoController
            }
        }
    }
}

// MARK: - TableView Methods

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSelectedSegment == 1 {
            return dailyTodo.count
        } else if currentSelectedSegment == 2 {
            return weeklyTodo.count
        } else {
            return monthlyTodo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell1 = tableView.dequeueReusableCell(
            withIdentifier: "TodoCell",
            for: indexPath
            ) as? TodoTableViewCell,
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoTableViewCell,
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoTableViewCell
            else { return UITableViewCell() }
        
        cell1.todoTitleLabel.text = dailyTodo[indexPath.row]
        cell2.todoTitleLabel.text = weeklyTodo[indexPath.row]
        cell3.todoTitleLabel.text = monthlyTodo[indexPath.row]
        
        if currentSelectedSegment == 1 {
            return cell1
        } else if currentSelectedSegment == 2 {
            return cell2
        } else {
            return cell3
        }
        
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let todo = fetchedResultsController.object(at: indexPath)
            todoController.deleteTodosFromServer(todo: todo) { result in
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
