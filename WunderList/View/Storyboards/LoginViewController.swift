//
//  LoginViewController.swift
//  WunderList
//
//  Created by Joe Veverka on 5/23/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var signUpSignInSegementedControl: UISegmentedControl!
    @IBOutlet weak var pinkSquareView: UIView!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    // MARK: - Properties
    ///Used to give access to TodoListViewController for passing data
    ///and/or triggering methods (such as setting up the UI after logging in)
    weak var delegate: TodoListViewController?
    var selectedLoginType: LoginType = .signIn {
        didSet {
            switch selectedLoginType {
            case .signUp:
                loginButtonOutlet.setTitle("Welcome Back!", for: .normal)
            case .signIn:
                loginButtonOutlet.setTitle("Get Started", for: .normal)
            }
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //customizing views
        self.nameTextField.addBottomBorder()
        self.passwordTextField.addBottomBorder()
        self.emailTextField.addBottomBorder()
        loginButtonOutlet.layer.cornerRadius = 12.0
        pinkSquareView.layer.cornerRadius = 10.0
        signUpSignInSegementedControl.backgroundColor = #colorLiteral(red: 0.3939243257, green: 0.3406436443, blue: 0.820184648, alpha: 0.7223886986)
        signUpSignInSegementedControl.selectedSegmentTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    // MARK: - Actions

    @IBAction func signUpSignInSegmentedAction(_ sender: UISegmentedControl) {
        switch signUpSignInSegementedControl.selectedSegmentIndex {
        case 0:
            selectedLoginType = .signIn
            passwordTextField.textContentType = .password
        default:
            selectedLoginType = .signUp
            passwordTextField.textContentType = .newPassword
        }
    }

    @IBAction func signInButtonAction(_ sender: UIButton) {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            name.isEmpty == false,
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false,
            let email = emailTextField.text,
            email.isEmpty == false else {
                return }
    }
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

     }
}

extension UITextField {
    func addBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = #colorLiteral(red: 0.03053783625, green: 0.003107197117, blue: 0.01022781059, alpha: 1)
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
