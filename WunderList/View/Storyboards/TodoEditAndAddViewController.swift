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

    var user = User()
    var todoController: TodoController?

    // MARK: - IBOutlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var recurringSegmentedControl: UISegmentedControl!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.addBottomBorder()

    }

// MARK: - Actions

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty else { return }

        let bodyText = bodyTextView.text!
        let recurringIndex = recurringSegmentedControl.selectedSegmentIndex
        let recurring = Recurring.allCases[recurringIndex]

        guard let todoRep = Todo(
            title: title,
            body: bodyText,
            recurring: recurring.rawValue,
            user: user
        ).todoRepresentation else { return }
        todoController?.sendTodosToServer(todo: todoRep)
        do {
            try CoreDataStack.shared.mainContext.save()
            dismiss(animated: true, completion: nil)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)

}
}
