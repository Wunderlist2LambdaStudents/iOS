//
//  TodoTableViewCell.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    //MARK: - Properties
    var todo: Todo? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Class funcs
    func updateViews() {
        guard let todo = todo else { return }
        todoTitleLabel.text = todo.title
    }
    
}

enum Alert {
    static func show(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }

    static func withYesNoPrompt(title: String, message: String, vc: UIViewController, complete: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            complete(true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            complete(false)
        }))
        vc.present(alert, animated: true)
    }
}
