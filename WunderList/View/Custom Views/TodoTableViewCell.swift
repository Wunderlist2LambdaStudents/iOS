//
//  TodoTableViewCell.swift
//  WunderList
//
//  Created by Marissa Gonzales on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var todoTitleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    var todo: Todo?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        func customInit(title: String, completeButton: UIButton) {
            self.todoTitleLabel.text = title
            self.completeButton = completeButton
            
            self.todoTitleLabel.textColor = .black
            self.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
}

