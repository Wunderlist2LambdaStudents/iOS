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
        guard let title = titleTextField.text, !title.isEmpty else { return }

        let bodyText = bodyTextView.text!
        let recurringIndex = recurringSegmentedControl.selectedSegmentIndex
        let recurring = Recurring.allCases[recurringIndex]
        let location = LocationRepresentation(xLocation: -8.783195, yLocation: -124.508523)
        let todoRep = TodoRepresentation(
            title: title,
            body: bodyText,
            dueDate: Date(),
            complete: true,
            recurring: recurring,
            location: location,
            creatorId: AuthService.activeUser?.identifier ?? UUID()
        )
        guard let user = user else { return }
        let todo = Todo(todoRepresentation: todoRep, userRep: user)
        #warning("This should be taken care of in the init, but it's nil")
        todo?.complete = todoRep.complete
        todoController?.sendTodosToServer(todo: todoRep)
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
