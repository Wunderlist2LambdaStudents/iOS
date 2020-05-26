//
//  TodoListViewController.swift
//  WunderList
//
//  Created by Kenny on 5/25/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {
    
    // Quick Dummy data
    var dailyTodo = ["Walk The Dog", "walk the Dog again"]
    var weeklyTodo = ["Pick Up Dog", "Feed Dog"]
    var monthlyTodo = ["Eat dog", "walk the dog again"]

    //MARK: -Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoBodyTextView: UITextView!
    
    @IBOutlet weak var switchTableViewSegmentedControlAction: UISegmentedControl!
    var currentSelectedSegment = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchTableViewSegmentedControlAction.backgroundColor = #colorLiteral(red: 0.3939243257, green: 0.3406436443, blue: 0.820184648, alpha: 0.7223886986)
        switchTableViewSegmentedControlAction.selectedSegmentTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)


    }
    
    
    func updateViews() {
        //update the view after the user is logged in
        if AuthService.activeUser != nil {
            //do work
        }
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

    }
}
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
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell

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
}
