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
        completeButton.set

    }
    
}
