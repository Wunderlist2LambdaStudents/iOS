//
//  TodoTableViewCell.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!

    // MARK: - Properties
    var todo: Todo? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Class Methods
    func updateViews() {
        guard let todo = todo else { return }

        todoTitleLabel.text = todo.title
    
        completeButton.setImage(todo.complete ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)
    }

    // MARK: - Actions

    @IBAction func completeButtonToggle(_ sender: UIButton) {

        guard let todo = todo else { return }
        todo.complete.toggle()

        sender.setImage(todo.complete ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle"), for: .normal)

                      do {
                          try CoreDataStack.shared.mainContext.save()
                      } catch {
                          NSLog("Error saving managed object context: \(error)")
                      }

    }

}
