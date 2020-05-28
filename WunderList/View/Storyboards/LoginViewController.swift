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
    @IBOutlet weak var emailScrollView: UIScrollView!

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
    var activeField: UITextField?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        //customizing views
        //        self.nameTextField.addBottomBorder()
        self.passwordTextField.addBottomBorder()
        self.emailTextField.addBottomBorder()
        loginButtonOutlet.layer.cornerRadius = 12.0
        pinkSquareView.layer.cornerRadius = 10.0
        signUpSignInSegementedControl.backgroundColor = #colorLiteral(red: 0.3939243257, green: 0.3406436443, blue: 0.820184648, alpha: 0.7223886986)
        signUpSignInSegementedControl.selectedSegmentTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        //accessibility identifiers
        signUpSignInSegementedControl.subviews[0].accessibilityIdentifier = "LoginViewController.SignUpSegment"
        signUpSignInSegementedControl.subviews[1].accessibilityIdentifier = "LoginViewController.SignInSegment"

        //handling keyboard
        self.emailScrollView.translatesAutoresizingMaskIntoConstraints = false
        //        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        //        nameTextField.tag = 1
        emailTextField.tag = 1
        passwordTextField.tag = 2

        //subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))

        //subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))

        //make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Unsubscribe from all our notifications
        unsubscribeFromAllNotifications()
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
        // We want this for production, skipping for development
        let authService = AuthService()
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false,
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            email.isEmpty == false,
            email != "testiOSUser" else {
                // login live test user
                // mock user will be loaded in mainVC if backend fails to login user
                // will remove this if backend isn't up soon so Mock user is always loaded
                authService.loginUser(with: "testiOSUser", password: "123456") {
                    DispatchQueue.main.async {
                        self.delegate?.updateViews()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return
        }
        //login actual user
        authService.loginUser(with: email, password: password) {
            DispatchQueue.main.async {
                self.delegate?.updateViews()
                self.dismiss(animated: true, completion: nil)
            }
        }

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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension LoginViewController {
    func initializeHideKeyboard() {
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))

        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }

    @objc func dismissMyKeyboard() {
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }

    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if let scrollView = emailScrollView,
            let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {

            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)

            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y

            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap

            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
