//
//  TodoEditAndAddViewController.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/27/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class TodoEditAndAddViewController: UIViewController {
    // MARK: - Properties

    var user = AuthService.activeUser
    var todoController: TodoController?
    var todo: Todo?

    // MARK: - IBOutlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var recurringSegmentedControl: UISegmentedControl!

    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - View Lifecycle
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.addBottomBorder()
        saveButton.layer.cornerRadius = 12.0
        addLocationButton.layer.cornerRadius = 12.0
        updateViews()
        hideKeyboardOnTap()
    }

    // MARK: - Actions

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
            !title.isEmpty,
            let bodyText = bodyTextView.text
        else { return }
        let recurringIndex = recurringSegmentedControl.selectedSegmentIndex
        //segmented control has 1 less beginning index due to .none not being there
        let recurring = Recurring.allCases[recurringIndex + 1]
        var todoRep = TodoRepresentation(
            identifier: UUID(),
            title: title,
            body: bodyText,
            dueDate: Date(),
            complete: true,
            recurring: recurring,
            creatorId: AuthService.activeUser?.identifier ?? UUID()
        )

        var todo = self.todo
        if todo == nil {
            guard let user = user else { return }
            todo = Todo(todoRepresentation: todoRep, userRep: user)
            #warning("This should be taken care of in the init, but it's nil")
            todo?.complete = todoRep.complete
            todoController?.sendTodosToServer(todo: todoRep)
        } else {
            guard let todo = todo else { return }
            todo.body = bodyText
            todo.title = title
            todo.recurring = recurring.rawValue
            todoRep.identifier = todo.identifier ?? UUID()
            try? todoController?.sendTodosToServer(todo: todoRep)
        }


        do {
            try CoreDataStack.shared.save()
            dismiss(animated: true, completion: nil)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        //should probably reset context here since this view controller has a live coredata object
        dismiss(animated: true, completion: nil)
    }

    private func updateViews() {
        titleTextField.text = todo?.title
        bodyTextView.text = todo?.body
        let recurring: Recurring

        if let todoRecurring = todo?.recurring {
            recurring = Recurring(rawValue: todoRecurring)!
        } else {
            recurring = .none
        }

        recurringSegmentedControl.selectedSegmentIndex = Recurring.allCases.firstIndex(of: recurring) ?? 0
    }
}

extension UIViewController {
    internal func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}
